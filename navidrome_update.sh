#!/bin/bash

set -e

ENV_FILE=".env"
DEFAULT_INSTALL_LOCATION="/opt/navidrome"

# Check for .env file or create one
if [ ! -f "$ENV_FILE" ]; then
    echo "$ENV_FILE not found. Creating a new one."
    read -p "Enter Navidrome user: " ND_USER
    read -p "Enter Navidrome group: " ND_GROUP
    read -p "Enter alternate install location [$DEFAULT_INSTALL_LOCATION]: " ND_INSTALL_LOCATION
    ND_INSTALL_LOCATION=${ND_INSTALL_LOCATION:-$DEFAULT_INSTALL_LOCATION}

    echo "ND_USER=$ND_USER" > $ENV_FILE
    echo "ND_GROUP=$ND_GROUP" >> $ENV_FILE
    echo "ND_INSTALL_LOCATION=$ND_INSTALL_LOCATION" >> $ENV_FILE
else
    echo "Loading variables from $ENV_FILE."
    source $ENV_FILE
fi

# Ask for version
read -p "Do you want the latest version? (y/n): " GET_LATEST
if [[ "$GET_LATEST" =~ ^[Yy]$ ]]; then
    echo "Fetching latest version..."
    LATEST_VERSION=$(curl -s https://api.github.com/repos/navidrome/navidrome/releases/latest | grep 'tag_name' | cut -d '"' -f 4)
else
    read -p "Enter the desired version (e.g., v0.XX.X): " LATEST_VERSION
fi

if [[ -z "$LATEST_VERSION" ]]; then
    echo "Error: Unable to fetch the latest version. Exiting."
    exit 1
fi

echo "Selected version: $LATEST_VERSION"

# Download the selected version
WGET_URL="https://github.com/navidrome/navidrome/releases/download/$LATEST_VERSION/navidrome_${LATEST_VERSION:1}_linux_amd64.tar.gz"
echo "Downloading $WGET_URL..."
wget $WGET_URL -O Navidrome.tar.gz

# Extract and set permissions
echo "Extracting Navidrome to $ND_INSTALL_LOCATION..."
sudo tar -xvzf Navidrome.tar.gz -C $ND_INSTALL_LOCATION

NAVIDROME_BINARY="$ND_INSTALL_LOCATION/navidrome"
echo "Setting executable permissions on $NAVIDROME_BINARY..."
sudo chmod +x $NAVIDROME_BINARY

echo "Setting ownership to $ND_USER:$ND_GROUP..."
sudo chown -R $ND_USER:$ND_GROUP $ND_INSTALL_LOCATION

# Clean up
echo "Cleaning up temporary files..."
rm -f Navidrome.tar.gz

# Restart Navidrome service
echo "Restarting Navidrome service..."
sudo systemctl restart navidrome

echo "Update complete!"
