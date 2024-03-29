#!/bin/bash

# Update package lists and upgrade packages
sudo apt update
sudo apt upgrade -y

# Install sudo if not already installed
if ! command -v sudo &> /dev/null; then
    apt-get install -y sudo
fi

# Prompt for username
read -p "Enter username: " username

# Prompt for password
read -s -p "Enter password: " password

# Create user
sudo adduser --quiet --disabled-password --shell /bin/bash --home /home/$username --gecos "User" $username

# Set password for user
echo "${username}:${password}" | sudo chpasswd

# Add user to sudo group
sudo usermod -aG sudo $username

# Check if .ssh directory exists
if [ ! -d "/home/$username/.ssh" ]; then
    sudo -u $username mkdir /home/$username/.ssh
    sudo -u $username chmod 700 /home/$username/.ssh
fi

# Check if authorized_keys file exists
if [ ! -f "/home/$username/.ssh/authorized_keys" ]; then
    sudo -u $username touch /home/$username/.ssh/authorized_keys
    sudo -u $username chmod 600 /home/$username/.ssh/authorized_keys
fi

# Add given SSH key to authorized keys
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGSOi7o7uKwo95KCvKwhLo2ZgHKaGKWK1nZ+XUCl3su9 homelab" | sudo -u $username tee -a /home/$username/.ssh/authorized_keys

# Disable password authentication for SSH
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
# Enable SSH key authentication
sudo sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/g' /etc/ssh/sshd_config
# Disable root SSH login
sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/g' /etc/ssh/sshd_config
sudo systemctl restart sshd
