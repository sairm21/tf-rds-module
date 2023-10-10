data "aws_ssm_parameter" "mysql_username" {
  name = "roboshop.${var.env}.mysql.username"
}

data "aws_ssm_parameter" "mysql_password" {
  name = "roboshop.${var.env}.mysql.password"
}