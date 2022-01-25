resource "aws_rds_cluster_instance" "cluster_instances" {
  count              = 2
  identifier         = "${var.app_name}-db-${count.index}"
  cluster_identifier = aws_rds_cluster.default.id
  instance_class     = var.rds_instance_class
  engine             = aws_rds_cluster.default.engine
  engine_version     = aws_rds_cluster.default.engine_version
  db_subnet_group_name = aws_db_subnet_group.default.name
  tags = merge(var.shared_tags, { Name = "${lookup(var.shared_tags, "Env", "")}-rds-${var.app_name}-db-${count.index}"})
}

resource "aws_rds_cluster" "default" {
  cluster_identifier = "aurora-cluster-${var.app_name}"
  availability_zones = values(var.private_subnet_cidrs)
  database_name      = var.database_name
  engine = "aurora-postgresql"
  deletion_protection = true
  master_username    = var.db_username
  master_password    = random_password.main.result
  db_subnet_group_name = aws_db_subnet_group.default.name
  vpc_security_group_ids = aws_db_security_group.default.id
  tags = merge(var.shared_tags, { Name = "${lookup(var.shared_tags, "Env", "")}-rds-aurora-cluster-${var.app_name}"})
}

resource "random_password" "main" {
  length           = 20
  special          = true
  override_special = "#!()_"
}

resource "aws_ssm_parameter" "rds_password" {
  name        = var.ssm_password_path
  description = "Master password for RDS ${var.app_name}"
  type        = "SecureString"
  value       = random_password.main.result
}

resource "aws_ssm_parameter" "rds_address" {
  name        = var.ssm_rds_address_path
  description = "Endpoint for RDS ${var.app_name}"
  type        = "SecureString"
  value       = aws_rds_cluster.default.endpoint
}

resource "aws_ssm_parameter" "rds_username" {
  name        = var.ssm_rds_username_path
  description = "Username for RDS ${var.app_name}"
  type        = "SecureString"
  value       = var.db_username
}
