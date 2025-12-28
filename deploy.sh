#!/bin/bash

# Deployment Script for Hostinger
# This script automates the deployment process for the Strapi CMS

set -e  # Exit on any error

echo "================================"
echo "Starting Deployment Process"
echo "================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if .env file exists
if [ ! -f .env ]; then
    echo -e "${RED}Error: .env file not found!${NC}"
    echo "Please create a .env file based on .env.production template"
    exit 1
fi

# Backup database (optional - requires database credentials)
echo -e "${YELLOW}Step 1: Creating database backup...${NC}"
BACKUP_DIR="./backups"
mkdir -p $BACKUP_DIR
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Uncomment and modify if you want automatic database backups
# mysqldump -u $DB_USER -p$DB_PASS $DB_NAME > $BACKUP_DIR/backup_$TIMESTAMP.sql
# echo -e "${GREEN}Database backup created: $BACKUP_DIR/backup_$TIMESTAMP.sql${NC}"

# Pull latest changes from Git (if using Git)
echo -e "${YELLOW}Step 2: Pulling latest changes from repository...${NC}"
if [ -d .git ]; then
    git pull origin main || git pull origin master
    echo -e "${GREEN}Repository updated successfully${NC}"
else
    echo -e "${YELLOW}Not a git repository, skipping...${NC}"
fi

# Install dependencies
echo -e "${YELLOW}Step 3: Installing dependencies...${NC}"
npm ci --production || npm install --production
echo -e "${GREEN}Dependencies installed successfully${NC}"

# Build the application
echo -e "${YELLOW}Step 4: Building the application...${NC}"
npm run build
echo -e "${GREEN}Build completed successfully${NC}"

# Create logs directory if it doesn't exist
mkdir -p ./logs

# Restart the application with PM2
echo -e "${YELLOW}Step 5: Restarting application with PM2...${NC}"
if pm2 list | grep -q "cms"; then
    echo "Application found in PM2, restarting..."
    pm2 restart ecosystem.config.js --env production
    echo -e "${GREEN}Application restarted successfully${NC}"
else
    echo "Application not found in PM2, starting for the first time..."
    pm2 start ecosystem.config.js --env production
    pm2 save
    echo -e "${GREEN}Application started successfully${NC}"
fi

# Display application status
echo -e "${YELLOW}Step 6: Checking application status...${NC}"
pm2 list
pm2 logs cms --lines 20 --nostream

echo ""
echo "================================"
echo -e "${GREEN}Deployment completed successfully!${NC}"
echo "================================"
echo ""
echo "Useful commands:"
echo "  pm2 logs cms       - View application logs"
echo "  pm2 monit          - Monitor application"
echo "  pm2 restart cms    - Restart application"
echo "  pm2 stop cms       - Stop application"
echo ""
