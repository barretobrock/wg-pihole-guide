# wg-pihole-guide
Standing guide to setting up a public wireguard + pihole adblocker

### Recommended System
 - Digital Ocean Droplet running Ubuntu 22.04

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
First, install Docker Engine. I followed [this guide](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-22-04)

```bash
# Install prereqs - though, they should already be included
sudo apt install apt-transport-https ca-certificates curl software-properties-common

# Add GPG key for official Docker repo
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repo to APT sources, then update
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update

# Make sure upcoming installation is from the Docker repo instead of default Ubuntu -- should be 5.20 or above
apt-cache policy docker-ce

# Install
sudo apt install docker-ce

# Confirm service is running
sudo systemctl status docker

# Bind user to docker group
sudo usermod -aG docker ${USER}
# Log out, then back in, then type:
su - ${USER}
# Enter that user's pw

# Confirm docker group is added to user:
groups
```

Next, we want to install docker-compose following [this guide](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-compose-on-ubuntu-22-04).

Get the latest release from [here](https://github.com/docker/compose/releases).

```bash
# Download
LATEST=v2.18.1
mkdir -p ~/.docker/cli-plugins/
curl -SL https://github.com/docker/compose/releases/download/${LATEST}/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose

# Set perms to make it executable
chmod +x ~/.docker/cli-plugins/docker-compose

# Verify that it runs correctly
docker compose version
```

## Clone repo
Clone this repo, which does everything we're looking to do, with the addition of adding unbound DNS
```bash
git clone https://github.com/barretobrock/wg-pihole-guide.git
cd wg-pihole-guide
```

Make changes to the `docker-compose.yml` file - timezones, main ip, pws, number of PEERS.
```bash
nano docker-compose.yml
```

Run with `docker compose up`. Scan QR codes, etc. When finished, CTRL+C to exit, and daemonize the command with `docker compose up -d`. 
Then, navigate to the PiHole Admin page to set up pihole.

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
### Updates
To update an existing container, remove the old one and start a new one.
```bash
docker compose up --force-recreate --build -d
docker image prune -f
```

To update pihole's blocklist via the cli, activate the container's shell env:
```bash
docker exec -it pihole bash
```
Note: you can find the container name with `docker container ls`

### Resources
 - [AdTester](https://fuzzthepiguy.tech/adtest/)
 - [DNS Leak Test](https://www.dnsleaktest.com/)
 - [Blocklist Sources](https://firebog.net/)