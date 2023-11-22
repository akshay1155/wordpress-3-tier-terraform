resource "aws_vpc" "demo_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "DemoVPC"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.demo_vpc.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = {
    Name = "PublicSubnet"
  }
}

resource "aws_subnet" "private_subnet_server" {
  vpc_id                  = aws_vpc.demo_vpc.id
  cidr_block              = "10.0.16.0/20"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"
  tags = {
    Name = "Public-Subnet-Server"
  }
}

resource "aws_subnet" "private_subnet_db_1" {
  vpc_id            = aws_vpc.demo_vpc.id
  cidr_block        = "10.0.32.0/20"
  availability_zone = "us-east-1c"
  tags = {
    Name = "PrivateSubnet-DB1"
  }
}
/*
resource "aws_subnet" "private_subnet_db_2" {
  vpc_id            = aws_vpc.demo_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1d"
  tags = {
    Name = "PrivateSubnet-DB2"
  }
}
*/
resource "aws_internet_gateway" "igw-demo" {
  vpc_id = aws_vpc.demo_vpc.id

  tags = {
    Name = "IGW-Demo"
  }
}

resource "aws_security_group" "public_instance_sg" {
  name   = "public-instance-sg"
  vpc_id = aws_vpc.demo_vpc.id
}
resource "aws_security_group_rule" "allow_ssh_sg" {
  type              = "ingress"
  description       = "SSH ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public_instance_sg.id
}
resource "aws_security_group_rule" "allow_http_sg" {
  type              = "ingress"
  description       = "HTTP ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public_instance_sg.id
}
resource "aws_security_group_rule" "allow_egress_sg" {
  type              = "egress"
  description       = "all traffic"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public_instance_sg.id
}

/*
resource "aws_db_subnet_group" "subnet_grp_rds" {
  //Subnet group for rds 
  name       = "rds-private-subnet-group"
  subnet_ids = ["${aws_subnet.private_subnet_db_1.id}", "${aws_subnet.private_subnet_db_2.id}"]
}

resource "aws_db_instance" "demodb" {
  //Resource block for RDS 
  allocated_storage      = 10
  db_name                = "mydb"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t3.micro"
  username               = "akshay"
  password               = "akshay1234"
  db_subnet_group_name   = aws_db_subnet_group.subnet_grp_rds.name
  vpc_security_group_ids = ["${aws_security_group.rds_db_sg.id}"]
  parameter_group_name   = "default.mysql5.7"
  skip_final_snapshot    = true
}
*/
resource "aws_security_group" "rds_db_sg" {
  name   = "rds-db-sg"
  vpc_id = aws_vpc.demo_vpc.id
}
resource "aws_security_group_rule" "allow_ssh_db_sg" {
  type              = "ingress"
  description       = "SSH ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.rds_db_sg.id
}
resource "aws_security_group_rule" "allow_db_port_sg" {
  type              = "ingress"
  description       = "HTTP ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.rds_db_sg.id
}
resource "aws_security_group_rule" "allow_egress_db_sg" {
  type              = "egress"
  description       = "all traffic"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.rds_db_sg.id
}


resource "aws_security_group" "private_server_sg" {
  name   = "private_server_sg"
  vpc_id = aws_vpc.demo_vpc.id
}
resource "aws_security_group_rule" "allow_ssh_private_sg" {
  type              = "ingress"
  description       = "SSH ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.private_server_sg.id
}
resource "aws_security_group_rule" "allow_http_private_sg" {
  type              = "ingress"
  description       = "HTTP ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.private_server_sg.id
}
resource "aws_security_group_rule" "allow_egress_private_sg" {
  type              = "egress"
  description       = "all traffic"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.private_server_sg.id
}

resource "aws_instance" "public_instance" {
  ami           = "ami-0fc5d935ebf8bc3bc"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public_subnet.id
  key_name = "demo"
  vpc_security_group_ids = [aws_security_group.public_instance_sg.id]
  tags = {
    Name = "Bastion Host"
  }
}

resource "aws_instance" "private_instance_server" {
  ami                    = "ami-0fc5d935ebf8bc3bc"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private_subnet_server.id
  key_name               = "demo"
  vpc_security_group_ids = [aws_security_group.private_server_sg.id]
  tags = {
    Name = "WordPress-Server"
  }
  user_data = <<-EOF
#!/bin/bash
sudo -i
apt update
apt install apache2 -y
apt install php php-mysql -y
echo '<?php phpinfo(); ?>' > /var/www/html/info.php
apt install mariadb-client php-mysql -y
cd /tmp && wget https://wordpress.org/latest.tar.gz
tar -xvf latest.tar.gz
cp -R wordpress /var/www/html/
chown -R www-data:www-data /var/www/html/wordpress/
chmod -R 755 /var/www/html/wordpress/
mkdir /var/www/html/wordpress/wp-content/uploads
chown -R www-data:www-data /var/www/html/wordpress/wp-content/uploads/

  EOF
}

resource "aws_instance" "db_instance_server" {
  ami                    = "ami-0fc5d935ebf8bc3bc"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private_subnet_db_1.id
  key_name               = "demo"
  vpc_security_group_ids = [aws_security_group.rds_db_sg.id]
  tags = {
    Name = "DB-Instance-Server"
  }
}

resource "aws_eip" "eip_demo" {

}

resource "aws_nat_gateway" "nat_01" {
  allocation_id = aws_eip.eip_demo.id
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = "NAT-01"
  }
  #depends_on = [aws_internet_gateway.example]
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.demo_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-demo.id
  }
  tags = {
    Name = "PublicRouteTable"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.demo_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_01.id
  }
  tags = {
    Name = "PrivateRouteTable"
  }
}
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.private_subnet_server.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "c" {
  subnet_id      = aws_subnet.private_subnet_db_1.id
  route_table_id = aws_route_table.private_route_table.id
}
/*
resource "aws_route_table_association" "d" {
  subnet_id      = aws_subnet.private_subnet_db_2.id
  route_table_id = aws_route_table.private_route_table.id
}
*/


