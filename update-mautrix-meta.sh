#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Variables
ENV_FILE=".env"

# Function to load variables from the .env file
load_env() {
  if [[ -f "$ENV_FILE" ]]; then
    echo "Loading configuration from $ENV_FILE..."
    source "$ENV_FILE"
  else
    echo "$ENV_FILE not found. Setting up for the first time..."
    setup_env
  fi
}

# Function to prompt user for variables and write them to .env
setup_env() {
  default_download_dir="$PWD"  # Default to current directory

  read -p "Enter temporary download directory (default: $default_download_dir): " download_dir
  DOWNLOAD_DIR=${download_dir:-"$default_download_dir"}

  read -p "Enter Facebook service directory (default: /opt/mautrix-meta-facebook): " facebook_dir
  FACEBOOK_DIR=${facebook_dir:-"/opt/mautrix-meta-facebook"}

  read -p "Enter Instagram service directory (default: /opt/mautrix-meta-instagram): " instagram_dir
  INSTAGRAM_DIR=${instagram_dir:-"/opt/mautrix-meta-instagram"}

  read -p "Enter Facebook service user (default: mautrix-meta-facebook): " facebook_user
  FACEBOOK_USER=${facebook_user:-"mautrix-meta-facebook"}

  read -p "Enter Instagram service user (default: mautrix-meta-instagram): " instagram_user
  INSTAGRAM_USER=${instagram_user:-"mautrix-meta-instagram"}

  read -p "Enter Facebook service group (default: matrix-synapse): " facebook_group
  FACEBOOK_GROUP=${facebook_group:-"matrix-synapse"}

  read -p "Enter Instagram service group (default: matrix-synapse): " instagram_group
  INSTAGRAM_GROUP=${instagram_group:-"matrix-synapse"}

  # Write to .env
  echo "Saving configuration to $ENV_FILE..."
  cat > "$ENV_FILE" <<EOL
DOWNLOAD_DIR="$DOWNLOAD_DIR"
FACEBOOK_DIR="$FACEBOOK_DIR"
INSTAGRAM_DIR="$INSTAGRAM_DIR"
FACEBOOK_USER="$FACEBOOK_USER"
INSTAGRAM_USER="$INSTAGRAM_USER"
FACEBOOK_GROUP="$FACEBOOK_GROUP"
INSTAGRAM_GROUP="$INSTAGRAM_GROUP"
EOL
}

# Function to detect system architecture
detect_arch() {
  ARCH=$(uname -m)
  case "$ARCH" in
    x86_64)   ARCH="amd64" ;;
    armv7l)   ARCH="arm" ;;
    aarch64)  ARCH="arm64" ;;
    arm64)    ARCH="arm64" ;; # macOS arm64
    *) 
      echo "Unsupported architecture: $ARCH"
      exit 1
      ;;
  esac
  echo "Detected architecture: $ARCH"
}

# Function to download the correct binary
download_binary() {
  echo "Fetching the latest release URL..."
  RELEASE_URL="https://github.com/mautrix/meta/releases/latest"
  
  # Follow the redirect and extract the final URL
  LATEST_RELEASE_URL=$(curl -sSLI -o /dev/null -w "%{url_effective}" "$RELEASE_URL")

  # Extract the tag name from the final redirected URL
  TAG=$(echo "$LATEST_RELEASE_URL" | grep -oP 'tag/\K[^/]+')

  if [[ -z "$TAG" ]]; then
    echo "Error: Unable to determine the latest release tag."
    exit 1
  fi

  DOWNLOAD_FILE="mautrix-meta-$ARCH"
  FULL_DOWNLOAD_LINK="https://github.com/mautrix/meta/releases/download/$TAG/$DOWNLOAD_FILE"

  echo "Latest release tag: $TAG"
  echo "Downloading the latest release for $ARCH from $FULL_DOWNLOAD_LINK..."
  mkdir -p "$DOWNLOAD_DIR"
  curl -sSL -o "$DOWNLOAD_DIR/$DOWNLOAD_FILE" "$FULL_DOWNLOAD_LINK"

  if [[ $? -ne 0 ]]; then
    echo "Error: Failed to download the file."
    exit 1
  fi
}

# Function to update a single service
update_service() {
  local SERVICE_DIR=$1
  local SERVICE_USER=$2
  local SERVICE_GROUP=$3
  local SERVICE_NAME=$4

  echo "Stopping $SERVICE_NAME service..."
  sudo systemctl stop "$SERVICE_NAME"

  echo "Replacing binary and setting permissions for $SERVICE_NAME..."
  sudo cp "$DOWNLOAD_DIR/mautrix-meta-$ARCH" "$SERVICE_DIR/mautrix-meta-$ARCH"
  sudo chmod +x "$SERVICE_DIR/mautrix-meta-$ARCH"
  sudo chown "$SERVICE_USER:$SERVICE_GROUP" "$SERVICE_DIR/mautrix-meta-$ARCH"

  echo "Starting $SERVICE_NAME service..."
  sudo systemctl start "$SERVICE_NAME"
}

# Load environment variables and detect architecture
load_env
detect_arch
download_binary

# Prompt to update services
echo "Which service(s) would you like to update?"
echo "1. Facebook only"
echo "2. Instagram only"
echo "3. Both Facebook and Instagram"
read -p "Enter your choice (1/2/3): " choice

case "$choice" in
  1)
    update_service "$FACEBOOK_DIR" "$FACEBOOK_USER" "$FACEBOOK_GROUP" "mautrix-meta-facebook"
    ;;
  2)
    update_service "$INSTAGRAM_DIR" "$INSTAGRAM_USER" "$INSTAGRAM_GROUP" "mautrix-meta-instagram"
    ;;
  3)
    update_service "$FACEBOOK_DIR" "$FACEBOOK_USER" "$FACEBOOK_GROUP" "mautrix-meta-facebook"
    update_service "$INSTAGRAM_DIR" "$INSTAGRAM_USER" "$INSTAGRAM_GROUP" "mautrix-meta-instagram"
    ;;
  *)
    echo "Invalid choice. Exiting."
    exit 1
    ;;
esac

# Cleanup
echo "Cleanup..."
rm -rf "$DOWNLOAD_DIR/mautrix-meta-$ARCH"

echo "Update completed successfully."
