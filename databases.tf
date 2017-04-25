

## Postgres RDS

resource "aws_db_instance" "circle_postgres" {  
  allocated_storage       = "${var.postgres_db_size}"
  backup_retention_period = "${var.postgres_db_backup_retention}"
  db_subnet_group_name    = "${aws_db_subnet_group.default.name}"
  engine                  = "postgres"
  engine_version          = "9.5.4"
  identifier              = "circle-pg"
  instance_class          = "db.m3.xlarge"
  multi_az                = true
  username                = "${var.postgres_db_master_user}"
  password                = "${var.postgres_db_master_password}"
  name                    = "${var.postgres_db_name}"
  port                    = 5432
  publicly_accessible     = false
  storage_encrypted       = true
  storage_type            = "io1"
  iops                    = "${var.postgres_db_iops}"
  vpc_security_group_ids  = ["${aws_security_group.circle_postgres_sg.id}"]
}

resource "aws_db_subnet_group" "default" {
    name       = "circle-dbsubnet"
    subnet_ids = ["${module.vpc.public_subnets}"]

    Tags {
        Name      = "circle-dbsubnet"
        Role      = "postgres"
        Terraform = "yes"
    }
}

resource "aws_security_group" "circle_postgres_sg" {  
  name        = "circle_postgres_sg"
  description = "RDS postgres servers (terraform-managed)"
  vpc_id      = "${module.vpc.vpc_id}"

  # Only postgres in
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["${var.cidr}"]
  }

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.cidr}"]
  }
}
