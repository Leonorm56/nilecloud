#!/usr/bin/env bash

# Colors
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Print colored heading
print_heading() {
    echo -e "${GREEN}$1${NC}"
}

# Print colored subheading
print_subheading() {
    echo -e "${YELLOW}$1${NC}"
}

print_heading "Updating NileCloud..."
git pull origin main

print_heading "Installing dependencies..."
pnpm install

print_heading "Running database migrations..."
pnpm db:migrate && pnpm db:seed

if [[ "$*" != *"--no-restart"* ]]; then
    print_heading "Restarting NileCloud with PM2..."
    pm2 restart ecosystem.config.cjs --update-env
    pm2 save
else
    print_subheading "Skipping PM2 restart (--no-restart flag specified)"
fi

ip=$(curl -s ifconfig.me)
print_heading "NileCloud updated!"
print_subheading "Server: http://$ip"