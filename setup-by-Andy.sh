#!/bin/bash

# Update and upgrade the system
sudo apt-get update
sudo apt-get upgrade -y

# Install Node.js 20 LTS
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install MariaDB server
sudo apt-get install -y mariadb-server

# Install PM2
sudo npm install pm2 -g

# Install PNPM
curl -fsSL https://get.pnpm.io/install.sh | sh -

# Install required libraries for Wine
sudo dpkg --add-architecture i386
sudo apt-get update
sudo apt-get install -y libstdc++6 libc6:i386 libncurses5:i386 libstdc++6:i386

# Install Wine
sudo apt-get install -y wine

# Configure MariaDB to allow remote access
sudo sed -i "s/bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mariadb.conf.d/50-server.cnf

# Modify SQL mode
sudo grep -q "^sql_mode" /etc/mysql/mariadb.conf.d/50-server.cnf && sudo sed -i '/^sql_mode/s/$/,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION/' /etc/mysql/mariadb.conf.d/50-server.cnf || echo 'sql_mode = "NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION"' | sudo tee -a /etc/mysql/mariadb.conf.d/50-server.cnf

# Start MariaDB service
sudo systemctl start mariadb

# Secure MariaDB installation (this step might ask for user input)
sudo mysql_secure_installation

# Ask for the new username and password
read -p "Masukkan username untuk admin mariadb kamu: " db_user
read -sp "Masukkan password untuk admin mariadb kamu: " db_password
echo

# Create a new user with all privileges
sudo mysql -u root <<EOF
CREATE USER '$db_user'@'%' IDENTIFIED BY '$db_password';
GRANT ALL PRIVILEGES ON *.* TO '$db_user'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF

# Restart MariaDB service to apply changes
sudo systemctl restart mariadb

echo "Instalasi selesai"

rm -- "$0"

