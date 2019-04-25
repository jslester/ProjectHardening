#!/bin/bash

# Make sure script is run as super user
if [ $EUID -ne 0 ]
		then echo "Please run command with sudo"
		exit
fi

# Update the system
sudo yum update

# Install Apache/PHP/MySQL (LAMP Stack)
sudo yum install httpd mariadb-server mariadb php php-mysql php-gd php-mbstring

# Enable Apache and MySQL to load on startup
sudo systemctl enable httpd.service
sudo systemctl enable mariadb.service

# Backup the base config file
sudo cp /etc/httpd/conf/httpd.conf /ect/httpd/conf/httpd.conf.original

# Modify the Apache config file
sudo sed -i -e 's/^[\t]*//' /etc/httpd/conf/httpd.conf
sudo sed -i "s|IncludeOptional|#IncludeOptional|" /etc/httpd/conf/httpd.conf
sudo sed -i "s|#ServerName www.example.com:80|ServerName localhost" /etc/httpd/conf/httpd.conf
sudo sed -i "s|DirectoryIndex index.html|DirectoryIndex index.php index.html|" /etc/httpd/conf/httpd.conf

# Add PHP configuration to Apache config file
echo "AddType application/x-httpd-php .php" | sudo tee -a /etc/httpd/conf/httpd.conf

#Start the MariaDB Service, then install MySQL
sudo systemctl start mariadb-service
sudo /usr/bin/mysql_secure_installation

# Start Apache
sudo systemctl start httpd.service

exit
