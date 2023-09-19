# Create Application Load Balancer (ALB)
resource "aws_lb" "my_alb" {
  name               = "terra-alb"
  internal           = false # Set to true if you want an internal ALB
  load_balancer_type = "application"
  subnets            = aws_subnet.public_subnet[*].id
  enable_deletion_protection = false # Set to true if you want deletion protection
  security_groups    = [aws_security_group.five.id]
}

# Create a listener for the ALB (e.g., HTTP traffic on port 80)
resource "aws_lb_listener" "my_listener" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      status_code  = "200"
    }
  }
}

# Create a target group for the ALB
resource "aws_lb_target_group" "my_target_group" {
  name     = "terra-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id
}

# Attach instances from public subnets to the ALB
resource "aws_lb_target_group_attachment" "public_instance_attachment_1" {
  target_group_arn = aws_lb_target_group.my_target_group.arn
  target_id        = aws_instance.one.id
}

resource "aws_lb_target_group_attachment" "public_instance_attachment_2" {
  target_group_arn = aws_lb_target_group.my_target_group.arn
  target_id        = aws_instance.two.id
}


# Associate the target group with the ALB listener
resource "aws_lb_listener_rule" "my_listener_rule" {
  listener_arn = aws_lb_listener.my_listener.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_target_group.arn
  }

  condition {
    path_pattern {
      values = ["/"]
    }
  }
}


 /*resource "aws_rds_cluster" "default" {
  cluster_identifier      = "aurora-cluster-demo"
  engine                  = "aurora-mysql"
  engine_version          = "5.7.mysql_aurora.2.11.2"
  availability_zones      = ["ap-south-1a", "ap-south-1b"]
  database_name           = "mydb"
  master_username         = "areeb"
  master_password         = "Areeb#444555"
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
}*/

resource "aws_instance" "nine" {
  for_each = toset(["one", "two", "three"])
  ami           = "ami-0899663faf239dd8a"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet[0].id
  key_name = "ALKeyPair"
  vpc_security_group_ids = ["${aws_security_group.five.id}"]
  availability_zone = "ap-south-1a"
  tags = {
    Name = "instance-${each.key}"
  }
}

