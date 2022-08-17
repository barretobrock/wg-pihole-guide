#/ server-setup.sh
#/  Run after sshing into the server as root
#/  Copy into server, enable 700 permissions

echo "Updating packages..."
sudo apt update && sudo apt upgrade

echo "Setting up user..."
# Grab new username
read -p 'New username: ' NEWUSER
adduser ${NEWUSER}
# Add user to sudo group
usermod -aG sudo ${NEWUSER}

echo "Configuring firewall"
# TODO: confirm ufw off
ufw allow OpenSSH
ufw enable
# TODO: confirm OpenSSH only
ufw status

echo "Configuring SSH access for user..."
rsync --archive --chown${NEWUSER}:${NEWUSER} ~/.ssh /home/${NEWUSER}


