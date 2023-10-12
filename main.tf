resource "aws_security_group" "mysql_sg" {
  name        = "${var.component}-${var.env}-SG"
  description = "Allow ${var.component}-${var.env}-Traffic"
  vpc_id = var.vpc_id

  ingress {
    description      = "Allow inbound traffic for ${var.component}-${var.env}"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    cidr_blocks      = var.sg_subnet_cidr
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = merge({
    Name = "${var.env}-${var.component}-SG"
  },
    var.tags)
}

resource "aws_db_subnet_group" "mysql_cluster_subent_group" {
  name       = "mysql_cluster_subent_group"
  subnet_ids = var.subnet_ids

  tags = merge({
    Name = "${var.env}-${var.component}-subnet-group"
  })
}

resource "aws_rds_cluster" "shipping" {
  cluster_identifier      = "shipping-dev"
  engine                  = var.engine
  engine_version          = var.engine_version
  database_name           = var.database_name
  master_username         = data.aws_ssm_parameter.mysql_username.value
  master_password         = data.aws_ssm_parameter.mysql_password.value
  db_subnet_group_name = aws_db_subnet_group.mysql_cluster_subent_group.name
  vpc_security_group_ids = [aws_security_group.mysql_sg.id]
  storage_encrypted = true
  kms_key_id = var.kms_key_id
  skip_final_snapshot  = true
  apply_immediately = true
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  count              = var.instance_count
  identifier         = "shipping-dev-instance-${count.index}"
  cluster_identifier = aws_rds_cluster.shipping.id
  instance_class     = var.instance_class
  engine             = var.engine
  engine_version     = var.engine_version
}