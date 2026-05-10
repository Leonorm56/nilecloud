#!/usr/bin/env bash

GREEN='\033[1;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_heading() { echo -e "${GREEN}$1${NC}"; }
print_subheading() { echo -e "${YELLOW}$1${NC}"; }

print_heading "Installing Nginx..."
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install nginx -y

print_heading "Installing Node.js LTS..."
if [ -d "$HOME/.nvm" ]; then
    print_subheading "NVM already installed."
else
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
    \. "$HOME/.nvm/nvm.sh"
    nvm install --lts
    npm i -g npm pnpm pm2
fi

print_heading "Setting up PM2 startup..."
startup_command=$(pm2 startup | grep "sudo env" | sed 's/^[[:space:]]*//')
[ -n "$startup_command" ] && eval "$startup_command"

print_heading "Cloning NileCloud..."
if [ -d "$HOME/nilecloud/.git" ]; then
    cd ~/nilecloud && git pull origin main
else
    git clone https://github.com/Leonorm56/nilecloud.git ~/nilecloud
    cd ~/nilecloud
fi

print_heading "Installing dependencies..."
pnpm install

print_heading "Configuring environment..."
if [ ! -f .env ]; then
    cp .env.example .env
    jwt_secret=$(node fly generate-jwt-secret | tail -n 1)
    sed -i "s/JWT_SECRET_KEY=\"\"/JWT_SECRET_KEY=\"$jwt_secret\"/" .env
fi

print_heading "Running database migrations..."
pnpm db:migrate && pnpm db:seed

print_heading "Starting NileCloud with PM2..."
pm2 restart ecosystem.config.cjs --update-env
pm2 save

print_heading "Configuring Nginx..."
sudo tee /etc/nginx/sites-available/nilecloud > /dev/null <<'EOF'
server {
    listen 80;
    listen [::]:80;
    server_name _;

    add_header Strict-Transport-Security "max-age=63072000" always;

    location / {
        proxy_http_version 1.1;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_pass http://127.0.0.1:3000;
    }
}
EOF

sudo rm -f /etc/nginx/sites-enabled/default
sudo ln -sf /etc/nginx/sites-available/nilecloud /etc/nginx/sites-enabled/nilecloud
sudo nginx -t && sudo systemctl reload nginx

ip=$(curl -s ifconfig.me)
print_heading "NileCloud is running!"
print_subheading "Server: http://$ip"
print_subheading "Set this as your Cloud Server URL in NileChain extension settings."
