# wordpress-3-tier-terraform
Terraform code for 3 tier architecture of wordpress using AWS 

- The architecture contains the following AWS Components:
        - VPC, Subnets, IGW, NAT gateway, RouteTables, EC2, ELB, RDS.
- First we created a VPC of CIDR block 10.0.0.0/16 
- Created 3 subnets - 2 public and 1 private
- The NAT Gateway is placed in a public subnet that contains LB.
- We created IGW and attached it to the VPC.
- The DB was placed in the private subnet and application server in one subnet and load   balancer in another subnet.
- Created 2 route tables, one for private subnet and one for public subnets.
- The routes of PublicRouteTable are configured such that the traffic from public subnets are forwarded to the destination IGW.
- The routes of PrivateRouteTable are configured such that the traffic from private subnets are forwarded to the destination NAT Gateway.
- For installing the wordpress server, we created an EC2 instance and placed it in a public subnet. 
- For the MySql database, we created another EC2 instance in the private instance and for accessing that private instance, we created a Bastion Host Instance in public subnet.
- The wordpress server installation commands are given as user data script, which will execute while our instance boots for the first time.
- For the instances, I have used a key file that I have generated before and giving its name demo at terraform code block of instances and placed it in the same folder of terraform files.
- Below was the user data script that we gave in wordpress server instance.

- User data script given for installing wordpress in EC2 instance:
> apt update && apt upgrade -y
> apt install apache2 -y
> apt install php php-mysql -y
> echo '<?php phpinfo(); ?>' > /var/www/html/info.php
> apt install mariadb-client php-mysql -y
> cd /tmp && wget https://wordpress.org/latest.tar.gz
> tar -xvf latest.tar.gz
> cp -R wordpress /var/www/html/
> chown -R www-data:www-data /var/www/html/wordpress/
> chmod -R 755 /var/www/html/wordpress/
> mkdir /var/www/html/wordpress/wp-content/uploads
> chown -R www-data:www-data /var/www/html/wordpress/wp-content/uploads/

- We have configured the security group of the wordpress server by allowing port 80 as inbound rule from the load balancer security group.

- For the database instance, the commands given for installing of the mysql database was:
> apt update && apt upgrade -y
> sudo apt install mariadb-server -y
> sudo mysql_secure_installation
> vi /etc/mysql/mariadb.conf.d/50-server.cnf   => change 121.0.0.1 to 0.0.0.0 for remote access.
> systemctl restart mysql
> mysql -u root -p
> create user 'wordpress' identified by 'wordpress-pass';
> grant all privileges on wordpress.* to wordpress;
> flush privileges;
> show databases;
> create database wordpress;
> exit

- For the database security group, we have been given access to the port 3306 from the security group of the wordpress server and 22 port from the bastion host security group.
- While creating load balancer we have given the two public subnets and created the target group and added the wordpress server to that target group. 
- For the security group of the load balancer we added port 80 for inbound rules.
- We can access our application at  load-balancer-dns/wordpress and can configure the wordpress setup.
- While setting the wordpress, give db name as wordpress, username as wordpress and password wordpress-pass and at database host give private IP of the wordpress-server instance, click submit and test configuration.
- After giving information about the wordpress server we can see the home page of the wordpress site and from next time while we access the home page link directly the home page opens.


- Our wordpress server can only be accessed through the loadbalancer and the database can only be accessed for the wordpress server only.


- How to run the terraform code?
- Download the code, ensure AWS CLI and terraform are installed in your system and give the following commands. Configure AWS through access keys if you haven't done before.
> terraform init
> terraform plan
> terraform apply -auto-approve

- For destroying the resources, > terraform destroy -auto-approve