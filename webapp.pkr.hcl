packer {
  required_plugins {
    amazon = {
      version = " >= 1.2.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "ssh_username" {
  type    = string
  default = "admin"
}

variable "subnet_id" {
  type    = string
  default = "subnet-005fd51a56ac28586"
}

variable "USER" {
  type    = string
  default = "${env("USER")}"
}

variable "DATABASE" {
  type    = string
  default = "${env("DATABASE")}"
}

variable "PD" {
  type    = string
  default = "${env("PD")}"
}

source "amazon-ebs" "webapp" {
  source_ami_filter {
    most_recent = true

    filters = {
      name                = "debian-12-*"
      architecture        = "x86_64"
      root-device-name    = "/dev/xvda"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    owners = ["amazon"]
  }

  ami_name        = "csye6225_iac_and_webapp_ami"
  ami_description = "AMI for CSYE6225"
  region          = "us-east-1"

  aws_polling {
    delay_seconds = 120
    max_attempts  = 50
  }

  instance_type = "t2.micro"
  ssh_username  = "admin"
  subnet_id     = var.subnet_id

  launch_block_device_mappings {
    device_name           = "/dev/xvda"
    volume_size           = 8
    volume_type           = "gp2"
    delete_on_termination = true
  }
}


build {
  sources = [
    "source.amazon-ebs.webapp"
  ]

  provisioner "file" {
    source      = "./users.csv"
    destination = "/home/admin/users.csv"
  }

  provisioner "file" {
    source = "./webapp.zip"
    destination = "/home/admin/webapp.zip"
  }

  provisioner "shell" {
    script = "./setup.sh"
    environment_vars = [
      "PD=${var.PD}",
      "DATABASE=${var.DATABASE}",
      "USER=${var.USER}"
    ]
  }
}