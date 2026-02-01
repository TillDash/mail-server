#!/bin/bash

# TillDash Mail Server Setup Script
# This script sets up and configures the mail server

set -e

echo "========================================="
echo "TillDash Mail Server Setup"
echo "========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo -e "${RED}This script should NOT be run as root${NC}"
   exit 1
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Docker is not installed. Please install Docker first.${NC}"
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker compose &> /dev/null; then
    echo -e "${RED}Docker Compose is not installed. Please install Docker Compose first.${NC}"
    exit 1
fi

# Create necessary directories
echo -e "${GREEN}Creating directory structure...${NC}"
mkdir -p docker-data/dms/mail-data
mkdir -p docker-data/dms/mail-state
mkdir -p docker-data/dms/mail-logs
mkdir -p docker-data/dms/config
mkdir -p docker-data/dms/config/ssl

# Copy environment file if it doesn't exist
if [ ! -f .env ]; then
    echo -e "${YELLOW}Creating .env file from template...${NC}"
    cp .env.example .env
    echo -e "${YELLOW}Please edit .env file with your configuration before proceeding${NC}"
    read -p "Press enter when ready to continue..."
fi

# Load environment variables
source .env

# Generate SSL certificates if they don't exist
if [ ! -f docker-data/dms/config/ssl/cert.pem ]; then
    echo -e "${GREEN}Generating self-signed SSL certificates...${NC}"
    echo -e "${YELLOW}For production, replace with Let's Encrypt or valid certificates${NC}"
    
    openssl req -x509 -newkey rsa:4096 -keyout docker-data/dms/config/ssl/key.pem \
        -out docker-data/dms/config/ssl/cert.pem -days 365 -nodes \
        -subj "/C=US/ST=State/L=City/O=TillDash/CN=${MAIL_HOSTNAME}"
    
    chmod 600 docker-data/dms/config/ssl/key.pem
    chmod 644 docker-data/dms/config/ssl/cert.pem
fi

# Start the mail server
echo -e "${GREEN}Starting mail server...${NC}"
docker compose up -d mailserver

# Wait for mail server to be ready
echo -e "${YELLOW}Waiting for mail server to initialize (this may take a minute)...${NC}"
sleep 30

# Setup email accounts
echo -e "${GREEN}Setting up email accounts...${NC}"
IFS=',' read -ra ACCOUNTS <<< "$MAIL_ACCOUNTS"
for account in "${ACCOUNTS[@]}"; do
    IFS='|' read -r email password <<< "$account"
    echo "Creating account: $email"
    docker compose exec -T mailserver setup email add "$email" "$password" || echo "Account may already exist"
done

# Generate DKIM keys
echo -e "${GREEN}Generating DKIM keys...${NC}"
docker compose exec mailserver setup config dkim

# Display DKIM DNS record
echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}DKIM DNS Record (add to DNS):${NC}"
echo -e "${GREEN}=========================================${NC}"
if [ -f docker-data/dms/config/opendkim/keys/${MAIL_DOMAIN}/mail.txt ]; then
    cat docker-data/dms/config/opendkim/keys/${MAIL_DOMAIN}/mail.txt
else
    echo -e "${YELLOW}DKIM keys will be generated on first startup${NC}"
fi

echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}Setup Complete!${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "1. Configure DNS records (see DNS-SETUP.md)"
echo "2. Test email sending with test-email.sh"
echo "3. Update TillDash backend .env with SMTP settings:"
echo "   EMAIL_HOST=${MAIL_HOSTNAME}"
echo "   EMAIL_PORT=587"
echo "   EMAIL_HOST_USER=support@${MAIL_DOMAIN}"
echo "   EMAIL_HOST_PASSWORD=your_password"
echo ""
echo -e "${YELLOW}Webmail Interface:${NC}"
echo "Access at: http://localhost:8080"
echo ""
echo -e "${YELLOW}View logs:${NC}"
echo "docker compose logs -f mailserver"
echo ""
