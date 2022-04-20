# wg-pihole-guide
Standing guide to setting up a public wireguard + pihole adblocker

## Initial droplet setup
First, set up the server from scratch (I used [this guide](https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-20-04) for DO droplets)
### Add new user
```bash
# Log in as root
ssh root@${ip}
# Update env just in case
sudo apt update && sudo apt upgrade
# Take in new user name
read -p 'New username: ' NEWUSER
# Make new user
adduser ${NEWUSER}
# Add new user to the sudo group
usermod -aG sudo ${NEWUSER}
```
### Set up firewall
```bash
ufw allow OpenSSH
ufw enable
# Make sure OpenSSH is shown as active
ufw status
```
### Enable external access
```bash
# We'll block any password auth in favor of SSH keys
rsync --archive --chown=${NEWUSER}:${NEWUSER} ~/.ssh /home/${NEWUSER}
```
### Confirm access
In another terminal window, try to `ssh` into the droplet with the `NEWUSER` name and run a `sudo echo` command to ensure it's running properly. 

## Install Docker Engine & Docker Compose
First, install Docker Engine. I followed [this guide](https://docs.docker.com/engine/install/ubuntu/)
```bash
sudo apt install ca-certificates curl gnupg lsb-release
# Add Docker's GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
# Set up stable repo
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
# Install
sudo apt-get update && sudo apt-get install docker-ce docker-ce-cli containerd.io
# Confirm proper setup:
sudo docker run hello-world
```

Next, we want to install docker-compose following [this guide](https://docs.docker.com/compose/install/).
```bash
# Run this curl command to download the most recent stable release of docker-compose-example.yml (confirm the version and always inspect the code before downloading!)
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose-example.yml
```
```bash
# Apply executable permissions to the binary
sudo chmod +x /usr/local/bin/docker-compose-example.yml
# Just for fun, create symbolic link to /usr/bin
sudo ln -s /usr/local/bin/docker-compose-example.yml /usr/bin/docker-compose-example.yml
```
```bash
# Lastly, test the installation
#   Note that the first time this was done, it hanged a bit? Second try was successful.
docker-compose-example.yml --version
```
## Clone repo
Clone this repo, which does everything we're looking to do, with the addition of adding unbound DNS
```bash
git clone https://github.com/IAmStoxe/wirehole.git
```

Make changes to the `docker-compose.yml` file, then run with `docker-compose up`. Scan QR codes, etc. When finished, CTRL+C to exit, and daemonize the command with `docker-compose up -d`. 
Then, navigate to http://10.2.0.100/admin to set up pihole.

## Extras
### PC Setup
```bash
# Install wireguard if not already
sudo apt install wireguard
# Grab the keys generated in the wireguard folder of the server (they'll start with 'peer_*') and add to wg0.conf for the client
sudo nano /etc/wireguard/wg0.conf
# Then connect
sudo wg-quick up wg0
```
