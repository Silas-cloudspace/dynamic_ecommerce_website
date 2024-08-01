# create database subnet group
# terraform aws db subnet group
resource "aws_db_subnet_group" "database_subnet_group" {
  name        = "database subnets"
  subnet_ids  = [aws_subnet.private_data_subnet_az1.id, aws_subnet.private_data_subnet_az2.id]
  description = "subnets for database instance"

  tags = {
    Name = "database subnets"
  }
}

# create database instance
# terraform aws db instance
resource "aws_db_instance" "database_instance" {
  availability_zone      = "eu-west-2b"
  allocated_storage      = 10
  identifier             = "dev-rds-db"
  engine                 = "mysql"
  engine_version         = "8.0.37"
  instance_class         = "db.t3.micro"
  username               = "choose one"
  password               = "choose one"
  db_subnet_group_name   = aws_db_subnet_group.database_subnet_group.name
  skip_final_snapshot    = true
  multi_az               = true
  vpc_security_group_ids = [aws_security_group.database_security_group.id]
}