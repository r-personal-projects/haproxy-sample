#!/bin/bash
# This script requests a new Let'sEncrypt cert for each specified domain, if needed.

# requires to run with sudo
if [[ $UID != 0 ]]; then
    echo "Please run this script with sudo:"
    echo "sudo $0 $*"
    exit 1
fi

# Setting the necessary variables:
LOG_PATH="/var/log/letsencrypt-renewal/"
LE_DIR="/srv/letsencrypt/"
LE_PORT="80"
LE_EMAIL="le@mail.com"
LE_NAME="ca-renewal-container"
CERT_DIR="/home/certs/"
# name of your proxy
CONTAINER_NAME="proxy"

# Providing the list of domains:
readarray DOMAINS < ./domains.list

# Stop Proxy to free up 80:80
../proxy/stop-hosting.sh

# The stuff below causes script output to be displayed on screen and redirected to a log
DATEVAR=$(date +%Y%m%d%H%M%S)
exec > >(tee -i "$LOG_PATH$DATEVAR"_installcert.log)
exec 2>&1

echo "############################################################"
echo "Executing installcert script. Logging started."
echo "############################################################"

# The code that requests certs and places them in the proper format, provided as a function for re-use:
request_cert() {
  # Run a temporary certbot container to request a certificate for the specified domain:
  echo "Running certbot container for $DOMAIN"
  docker run --rm --name $LE_NAME -p $LE_PORT:$LE_PORT -v $LE_DIR"etc:/etc/letsencrypt" -v $LE_DIR"var:/var/lib/letsencrypt" certbot/certbot:latest certonly --standalone -d $DOMAIN --non-interactive --preferred-challenges http --agree-tos --email $LE_EMAIL --http-01-port=$LE_PORT

  # Grab the content of fullchain and privkey and combine them in $DOMAIN.pem (HAProxy requires this):
  echo
  echo "Placing pem file for $DOMAIN"
  bash -c "cat $LE_DIR\"etc/live/\"$DOMAIN\"/fullchain.pem\" $LE_DIR\"etc/live/\"$DOMAIN\"/privkey.pem\" > $CERT_DIR/$DOMAIN.pem"
}

# Run request_cert function for every domain:
for DOMAIN in "${DOMAINS[@]}"
do
  echo "$DOMAIN will be: $(grep -o '[a-z|.|-]*' <<< $DOMAIN | head -1)"
  DOMAIN=$(grep -o '[a-z|.|-]*' <<< $DOMAIN | head -1)
  echo
  echo "############################################################"
  echo "Calling request_cert function for $DOMAIN"
  echo "############################################################"
  request_cert $DOMAIN
  echo
done

# Reload config of container:
echo "############################################################"
echo "Reloading HAProxy configuration."
echo "############################################################"
../proxy/reinit.sh
echo

echo "############################################################"
echo "Script installcert finished."
echo "############################################################"