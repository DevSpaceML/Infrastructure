#!/bin/bash

# install nginx webserver
echo "Installing nginx webserver on EC2 instance..."
yum update -y
yum install -y nginx
echo "Nginx installed:"
nginx -v

#start and enable nginx service
echo "Starting and enabling nginx service..."
systemctl start nginx
systemctl enable nginx

# create python virtual environment
echo "Creating python virtual environment for nginx server..."
python3 -m venv /opt/nginx_env
source /opt/nginx_env/bin/activate

# intall FastAPI and uWSGI
echo "Installing FastAPI and uWSGI in the virtual environment..."
pip install fastapi
pip install uWsgi

# create app destination and copy files
echo "Creating app destination and copying files..."
sudo mkdir -p /app
sudo chown -R $USER:$USER /app
cd /app
pip install requirements.txt