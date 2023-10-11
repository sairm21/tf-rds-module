resource "aws_db_subnet_group" "mysql_cluster_group" {
  name       = "${var.env}-${var.component}-subnet_group"
  subnet_ids = var.subnet_ids

  tags = merge({
    Name = "${var.env}-${var.component}-subnet_group"
  },
    var.tags)
}

resource "aws_rds_cluster" "shipping" {
  cluster_identifier      = "${var.component}-${var.env}"
  engine                  = var.engine
  engine_version          = var.engine_version
  database_name           = var.database_name
  master_username         = data.aws_ssm_parameter.mysql_username.value
  master_password         = data.aws_ssm_parameter.mysql_password.value
  db_subnet_group_name = aws_db_subnet_group.mysql_cluster_group.name
  kms_key_id = var.kms_key_id
}