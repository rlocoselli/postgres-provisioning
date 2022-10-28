provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region = var.region
}

data "aws_ami" "aws-linux2" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = ["amzn-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_default_vpc" "default" {
  
}

resource "aws_security_group" "allow_ssh_postgres" {
  name = "allow_ssh_postgres"
  description = "Allow SSH access"
  vpc_id = aws_default_vpc.default.id
  ingress {
    protocol = "tcp"
    from_port = 22
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol = "tcp"
    from_port = 5432
    to_port = 5435
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol = "tcp"
    from_port = 80
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol = -1
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "mypostgresprovisioning" {
    ami = data.aws_ami.aws-linux2.id
    instance_type = "t2.micro"
    key_name = var.key_name
    vpc_security_group_ids = [aws_security_group.allow_ssh_postgres.id]

    connection {
        type = "ssh"
        host = self.public_ip
        user = "ec2-user"
        private_key = file(var.private_key_path)
    }

    provisioner "remote-exec" {
        inline = [
            "sudo yum -y install postgresql-server",
            "sudo service postgresql initdb",
            "sudo chkconfig postgresql on",
            "sudo service postgresql restart",
            "sudo -u postgres psql -d postgres -c \"alter user postgres with encrypted password 'test';\"",
        ]
    }

    provisioner "file" {
      source      = "pg_hba.conf"
      destination = "/tmp/pg_hba.conf"

    }

    provisioner "file" {
      source      = "postgresql.conf"
      destination = "/tmp/postgresql.conf"
    }

    provisioner "remote-exec" {
        inline = [
            "sudo cp /tmp/pg_hba.conf /var/lib/pgsql9/data/pg_hba.conf",
            "sudo cp /tmp/postgresql.conf /var/lib/pgsql9/data/postgresql.conf",
        ]
    }
}

output "mypostgresprovisioning_public_ip" {
    value = aws_instance.mypostgresprovisioning.public_ip
}