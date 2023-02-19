#!/bin/bash

# Update the package list and install Apache2, PHP, PHP MySQLi, Git, and MariaDB
apt-get update -y
apt-get install apache2 php php-mysqli php-mysql git mariadb-server -y

# Start Apache2 service
service apache2 start

# Clone the shn repository to /var/www/
cd /var/www/ && git clone https://github.com/kachenchaney/shn.git

# Give permission to access asset directory and index.php file
chmod 777 -R /var/www/shn/

# Replace the default Apache2 configuration with the custom configuration
cd /etc/apache2/sites-available/
rm -r /etc/apache2/sites-available/000-default.conf
cp /var/www/shn/asset/shell/000-default.conf .
rm ../sites-enabled/000-default.conf
cp 000-default.conf ../sites-enabled/
cd ../../../

# Restart Apache2 service
systemctl restart apache2

# Modify the file koneksi.php to use the RDS database
sed -i 's/localhost/database/g' /var/www/shn/asset/koneksi.php
sed -i 's/root/admin/g' /var/www/shn/asset/koneksi.php
sed -i 's/\"\"/\"admin123\"/g' /var/www/shn/asset/koneksi.php

# Check if the modification was successful
if [ $? -eq 0 ]; then
  echo "File koneksi.php has been successfully modified."
else
  echo "Failed to modify the file koneksi.php."
fi

# Login to the RDS database
mysql -h database -u admin -p << EOF

# Show existing databases
show databases;

# Create the datasiswa database
create database datasiswa;

# Use the datasiswa database
use datasiswa;

# Import the SQL script to create tables and populate data
source /var/www/shn/asset/database/datasiswa.sql

# Show tables in the datasiswa database
show tables;

# Select data from the users table
SELECT * FROM users;

# Exit the MySQL prompt
EOF
