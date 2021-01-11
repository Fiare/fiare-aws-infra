provider "aws" {
  region = var.region
}

variable "azs" {
  default = "eu-west-1b, eu-west-1c"
}

resource "aws_vpc" "main" {
  cidr_block = "10.123.0.0/16"
}

# Creating one subnet in each AZ
resource "aws_subnet" "private" {
  vpc_id = "${aws_vpc.main.id}"
  count             = "${length(split(",", var.azs))}"
  availability_zone = "${element(split(",", var.azs), count.index)}"
  cidr_block        = "10.123.${count.index}.0/24"
}
resource "aws_rds_cluster" "rdsmain" {
  cluster_identifier     = "aurora-main"
  database_name          = "foobar"
  master_username        = "user"
  master_password        = "passpass"
  vpc_security_group_ids = [ "${aws_security_group.rds.id}" ]
  db_subnet_group_name   = "${aws_db_subnet_group.rdsmain_private.name}"
}

resource "aws_rds_cluster_instance" "rdsmain_instance" {
  count                = 2
  identifier           = "instance-0${count.index + 1}"
  cluster_identifier   = "${aws_rds_cluster.rdsmain.id}"
  instance_class       = "db.r3.large"
  db_subnet_group_name = "${aws_db_subnet_group.rdsmain_private.name}"
}

resource "aws_db_subnet_group" "rdsmain_private" {
  name        = "rdsmain-private"
  description = "Private subnets for RDS instance"
  subnet_ids  = [ "${aws_subnet.private.*.id}" ]
}

resource "aws_security_group" "rds" {
  name        = "rds-sg"
  description = "Allow MySQL traffic to rds"
  vpc_id      = "${aws_vpc.main.id}"
}

resource "aws_security_group_rule" "public_to_rds" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  security_group_id = "${aws_security_group.rds.id}"
  cidr_blocks       = ["10.0.0.0/16"]
}