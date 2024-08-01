# create a key pair
resource "aws_key_pair" "generated_key_pair" {
  key_name   = "ec2_key"  # This should be a simple name without special characters
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDJY9ZInM62Es7HqXfSRASeT1zL07orcsvT3kQl4MVJHTj4/X+S1S7EvNH5OZk1U19WzjTOHIrs2q1QYyZRSEzMu88IALtlHqvdknSezbr291GuNHzftsaa1oVBPIyvX+zFDitlQtbMvgaT0n64IGfwDf8C0vo8VcYNYebX8cks+CFnHGizyTa9EJJYcXpgPebo+v0g1bORCc9ETof437jRIMO7KE2ZGUujTET4MY13C7xzkjgquTz4q22f1kmgwXNTUKuq7yZjwGpsdu3a7sW6VdevsB5kHZq2ZYdn/uqqRnaBvS+s71Tz0iAyl4tZxe+UCDhWoUrxddjIg7uxQH5x silas@Silas"
  # Ensure the public key is correctly formated and valid
}

# Define the launch template
resource "aws_launch_template" "webserver_launch_template" {
  name          = "dev-launch-template"
  image_id      = "ami-046d5130831576bbb"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.generated_key_pair.key_name
  description   = "launch template for asg"

  monitoring {
    enabled = true 
  }

  vpc_security_group_ids = [aws_security_group.webserver_security_group.id]

  user_data = base64encode(<<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y httpd
              sudo systemctl enable httpd
              sudo systemctl start httpd

              sudo yum install -y \
              php \
              php-pdo \
              php-openssl \
              php-mbstring \
              php-exif \
              php-fileinfo \
              php-xml \
              php-ctype \
              php-json \
              php-tokenizer \
              php-curl \
              php-cli \
              php-fpm \
              php-mysqlnd \
              php-bcmath \
              php-gd \
              php-cgi \
              php-gettext \
              php-intl \
              php-zip

              sudo wget https://dev.mysql.com/get/mysql80-community-release-el9-1.noarch.rpm
              sudo dnf install -y mysql80-community-release-el9-1.noarch.rpm
              sudo rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2023
              sudo dnf install -y mysql-community-server
              sudo systemctl start mysqld
              sudo systemctl enable mysqld

              sudo sed -i '/<Directory "\\/var\\/www\\/html">/,/<\\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/httpd/conf/httpd.conf

              # Install aws-cli if not already installed
              sudo yum install -y aws-cli

              # Download and unzip the application code from S3
              aws s3 cp s3://code-for-webserver-st/shopwise.zip /var/www/html/shopwise.zip
              sudo unzip /var/www/html/shopwise.zip -d /var/www/html/
              sudo rm -rf /var/www/html/shopwise.zip
              sudo chmod -R 777 /var/www/html
              sudo chmod -R 777 /var/www/html/storage/

              sudo service httpd restart
              EOF
  )
}

# create auto scaling group
# terraform aws autoscaling group
resource "aws_autoscaling_group" "auto_scaling_group" {
  vpc_zone_identifier = [aws_subnet.private_app_subnet_az1.id, aws_subnet.private_app_subnet_az2.id]
  desired_capacity    = 2
  max_size            = 4
  min_size            = 1
  name                = "dev-asg"
  health_check_type   = "ELB"

  launch_template {
    name    = aws_launch_template.webserver_launch_template.name
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "asg-webserver"
    propagate_at_launch = true
  }

  lifecycle {
    ignore_changes      = [target_group_arns]
  }
}

# attach auto scaling group to alb target group
# terraform aws autoscaling attachment
resource "aws_autoscaling_attachment" "asg_alb_target_group_attachment" {
  autoscaling_group_name = aws_autoscaling_group.auto_scaling_group.id
  lb_target_group_arn    = aws_lb_target_group.alb_target_group.arn
}

# create an auto scaling group notification
# terraform aws autoscaling notification
resource "aws_autoscaling_notification" "webserver_asg_notifications" {
  group_names = [aws_autoscaling_group.auto_scaling_group.name]

  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
  ]

  topic_arn = aws_sns_topic.user_updates.arn
}