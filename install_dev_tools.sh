#!/bin/bash

echo "Installing DEV tools..."

# Docker
if ! command -v docker &> /dev/null; then
  echo "Installing Docker..."
  curl -fsSL https://get.docker.com -o get-docker.sh
  sh get-docker.sh
  sudo usermod -aG docker "$USER"
  rm get-docker.sh
else
  echo "Docker already installed"
fi

# Docker Compose
if ! command -v docker-compose &> /dev/null; then
  echo "Installing Docker Compose..."
  sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
    -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
else
  echo "Docker Compose already installed"
fi

# Python 3.9+
PYTHON_VERSION=$(python3 --version 2>/dev/null | awk '{print $2}' || echo "0")
REQUIRED_PYTHON="3.9"

version_gte() {
  printf '%s\n%s\n' "$2" "$1" | sort -C -V
}

if ! version_gte "$PYTHON_VERSION" "$REQUIRED_PYTHON"; then
  echo "Installing Python 3.9..."
  sudo apt update
  sudo apt install -y software-properties-common
  sudo add-apt-repository -y ppa:deadsnakes/ppa
  sudo apt update
  sudo apt install -y python3.9 python3.9-venv python3.9-distutils
else
  echo "Python $PYTHON_VERSION alrerady installed"
fi

# pip
if ! command -v pip3 &> /dev/null; then
  echo "Installing pip..."
  sudo apt install -y python3-pip
else
  echo "pip already installed"
fi

# Django
if ! python3 -m django --version &> /dev/null; then
  echo "Installing Django..."
  pip3 install Django
else
  echo "Django already installed"
fi

echo "Installing DEV tools ... DONE!"
