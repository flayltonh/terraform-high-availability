# =============================================
# User Data Script (mostra a AZ na página HTML)
# =============================================
locals {
  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd

    # Obtém a Zona de Disponibilidade via IMDSv2
    TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
      -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
    AZ=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
      http://169.254.169.254/latest/meta-data/placement/availability-zone)
    INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
      http://169.254.169.254/latest/meta-data/instance-id)

    # Cria a página HTML
    cat > /var/www/html/index.html <<HTML
    <!DOCTYPE html>
    <html lang="pt-br">
    <head>
      <meta charset="UTF-8">
      <title>Alta Disponibilidade AWS</title>
      <style>
        body { font-family: Arial, sans-serif; background: #f0f2f5; display: flex;
               justify-content: center; align-items: center; height: 100vh; margin: 0; }
        .card { background: white; border-radius: 12px; padding: 40px 60px;
                box-shadow: 0 4px 20px rgba(0,0,0,0.1); text-align: center; }
        h1 { color: #232f3e; margin-bottom: 8px; }
        .az  { font-size: 2rem; font-weight: bold; color: #ff9900; margin: 20px 0; }
        .iid { font-size: 0.9rem; color: #666; }
        .badge { background: #232f3e; color: #ff9900; padding: 6px 16px;
                 border-radius: 20px; font-size: 0.85rem; margin-top: 16px; display: inline-block; }
      </style>
    </head>
    <body>
      <div class="card">
        <h1>&#x2705; Arquitetura 3 Camadas AWS</h1>
        <p>Esta requisição foi servida por:</p>
        <div class="az">$AZ</div>
        <div class="iid">Instance ID: $INSTANCE_ID</div>
        <div class="badge">Alta Disponibilidade Ativa</div>
      </div>
    </body>
    </html>
    HTML

    systemctl start httpd
    systemctl enable httpd
  EOF
  )
}

# =============================================
# Application Load Balancer
# =============================================
resource "aws_lb" "main" {
  name               = "${var.project_name}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = {
    Name = "${var.project_name}-${var.environment}-alb"
  }
}

# =============================================
# Target Group
# =============================================
resource "aws_lb_target_group" "web" {
  name     = "${var.project_name}-${var.environment}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-tg"
  }
}

# =============================================
# Listener HTTP
# =============================================
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

# =============================================
# Launch Template
# =============================================
resource "aws_launch_template" "web" {
  name_prefix   = "${var.project_name}-${var.environment}-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type

  user_data = local.user_data

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.web_sg_id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.project_name}-${var.environment}-web-instance"
      Environment = var.environment
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# =============================================
# Auto Scaling Group
# =============================================
resource "aws_autoscaling_group" "web" {
  name                = "${var.project_name}-${var.environment}-asg"
  desired_capacity    = var.asg_desired_capacity
  min_size            = var.asg_min_size
  max_size            = var.asg_max_size
  vpc_zone_identifier = var.private_subnet_ids
  target_group_arns   = [aws_lb_target_group.web.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  dynamic "tag" {
    for_each = {
      Name        = "${var.project_name}-${var.environment}-asg-instance"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# =============================================
# Auto Scaling Policies
# =============================================
resource "aws_autoscaling_policy" "scale_out" {
  name                   = "${var.project_name}-${var.environment}-scale-out"
  autoscaling_group_name = aws_autoscaling_group.web.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 300
}

resource "aws_autoscaling_policy" "scale_in" {
  name                   = "${var.project_name}-${var.environment}-scale-in"
  autoscaling_group_name = aws_autoscaling_group.web.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 300
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.project_name}-${var.environment}-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "Escala para cima quando CPU >= 70%"
  alarm_actions       = [aws_autoscaling_policy.scale_out.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web.name
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "${var.project_name}-${var.environment}-cpu-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 20
  alarm_description   = "Escala para baixo quando CPU <= 20%"
  alarm_actions       = [aws_autoscaling_policy.scale_in.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web.name
  }
}
