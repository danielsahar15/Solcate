resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = var.tags
}

resource "aws_db_instance" "this" {
  identifier = var.name

  engine         = "postgres"
  engine_version = "15"

  instance_class = var.instance_class
  allocated_storage = var.allocated_storage
  storage_type       = "gp3"

  db_name  = var.db_name
  username = var.username
  password = var.password

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.security_group_id]

  publicly_accessible = false
  multi_az            = var.multi_az

  backup_retention_period = 7
  skip_final_snapshot     = true

  tags = var.tags
}
