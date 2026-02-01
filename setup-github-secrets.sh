#!/bin/bash

# GitHub Secrets Setup Script for TillDash Mail Server
# This script sets up all required secrets in GitHub repository

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

REPO="tilldash/mail-server"

echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}GitHub Secrets Setup for Mail Server${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo -e "${RED}GitHub CLI (gh) is not installed.${NC}"
    echo "Install it with: brew install gh"
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo -e "${YELLOW}Not authenticated with GitHub. Running authentication...${NC}"
    gh auth login
fi

echo -e "${YELLOW}This script will set up GitHub secrets for the mail server.${NC}"
echo "Repository: $REPO"
echo ""

# Collect environment variables
read -p "Mail domain (e.g., tilldash.com): " MAIL_DOMAIN
read -p "Mail hostname (e.g., mail.tilldash.com): " MAIL_HOSTNAME
read -p "Server public IP address: " SERVER_PUBLIC_IP

echo ""
echo -e "${YELLOW}Email Accounts Setup${NC}"
echo "You can add multiple accounts. Press Enter without input to finish."
MAIL_ACCOUNTS=""
while true; do
    read -p "Email address (or press Enter to finish): " EMAIL
    if [ -z "$EMAIL" ]; then
        break
    fi
    read -sp "Password for $EMAIL: " PASSWORD
    echo ""
    
    if [ -z "$MAIL_ACCOUNTS" ]; then
        MAIL_ACCOUNTS="$EMAIL|$PASSWORD"
    else
        MAIL_ACCOUNTS="$MAIL_ACCOUNTS,$EMAIL|$PASSWORD"
    fi
done

if [ -z "$MAIL_ACCOUNTS" ]; then
    echo -e "${RED}At least one email account is required${NC}"
    exit 1
fi

# SSL Configuration
echo ""
echo -e "${YELLOW}SSL Configuration${NC}"
echo "1. Manual (self-signed or custom certificates)"
echo "2. Let's Encrypt (automatic)"
read -p "Choose SSL type [1/2]: " SSL_CHOICE

if [ "$SSL_CHOICE" == "2" ]; then
    SSL_TYPE="letsencrypt"
    read -p "Let's Encrypt email: " LETSENCRYPT_EMAIL
else
    SSL_TYPE="manual"
fi

# Deployment Configuration
echo ""
echo -e "${YELLOW}Deployment Configuration${NC}"
read -p "EC2 instance public IP (for deployment): " EC2_PUBLIC_IP
read -sp "EC2 SSH private key path: " SSH_KEY_PATH
echo ""

if [ -f "$SSH_KEY_PATH" ]; then
    EC2_SSH_KEY=$(cat "$SSH_KEY_PATH")
else
    echo -e "${RED}SSH key file not found: $SSH_KEY_PATH${NC}"
    exit 1
fi

# AWS Configuration (optional)
echo ""
read -p "AWS Route 53 Hosted Zone ID (optional, press Enter to skip): " HOSTED_ZONE_ID

echo ""
echo -e "${GREEN}Setting up GitHub secrets...${NC}"

# Set secrets
gh secret set MAIL_DOMAIN -b "$MAIL_DOMAIN" -R "$REPO"
echo "✓ MAIL_DOMAIN"

gh secret set MAIL_HOSTNAME -b "$MAIL_HOSTNAME" -R "$REPO"
echo "✓ MAIL_HOSTNAME"

gh secret set SERVER_PUBLIC_IP -b "$SERVER_PUBLIC_IP" -R "$REPO"
echo "✓ SERVER_PUBLIC_IP"

gh secret set MAIL_ACCOUNTS -b "$MAIL_ACCOUNTS" -R "$REPO"
echo "✓ MAIL_ACCOUNTS"

gh secret set SSL_TYPE -b "$SSL_TYPE" -R "$REPO"
echo "✓ SSL_TYPE"

if [ "$SSL_TYPE" == "letsencrypt" ]; then
    gh secret set LETSENCRYPT_EMAIL -b "$LETSENCRYPT_EMAIL" -R "$REPO"
    gh secret set LETSENCRYPT_HOST -b "$MAIL_HOSTNAME" -R "$REPO"
    echo "✓ LETSENCRYPT_EMAIL"
    echo "✓ LETSENCRYPT_HOST"
fi

gh secret set EC2_PUBLIC_IP -b "$EC2_PUBLIC_IP" -R "$REPO"
echo "✓ EC2_PUBLIC_IP"

gh secret set EC2_SSH_PRIVATE_KEY -b "$EC2_SSH_KEY" -R "$REPO"
echo "✓ EC2_SSH_PRIVATE_KEY"

if [ -n "$HOSTED_ZONE_ID" ]; then
    gh secret set AWS_HOSTED_ZONE_ID -b "$HOSTED_ZONE_ID" -R "$REPO"
    echo "✓ AWS_HOSTED_ZONE_ID"
fi

# Optional: Set AWS credentials if using Route 53
read -p "Do you want to set AWS credentials for Route 53 automation? [y/N]: " USE_AWS
if [[ "$USE_AWS" =~ ^[Yy]$ ]]; then
    read -p "AWS Access Key ID: " AWS_ACCESS_KEY
    read -sp "AWS Secret Access Key: " AWS_SECRET_KEY
    echo ""
    
    gh secret set AWS_ACCESS_KEY_ID -b "$AWS_ACCESS_KEY" -R "$REPO"
    gh secret set AWS_SECRET_ACCESS_KEY -b "$AWS_SECRET_KEY" -R "$REPO"
    echo "✓ AWS_ACCESS_KEY_ID"
    echo "✓ AWS_SECRET_ACCESS_KEY"
fi

echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}GitHub Secrets Setup Complete!${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo "Secrets have been added to: https://github.com/$REPO/settings/secrets/actions"
echo ""
echo "Next steps:"
echo "1. Push your code to the repository"
echo "2. GitHub Actions will automatically deploy the mail server"
echo "3. Configure DNS records (see DNS-SETUP.md)"
echo "4. Verify deployment and test email sending"
echo ""
echo "View secrets:"
echo "  gh secret list -R $REPO"
echo ""
echo "Update a secret:"
echo "  gh secret set SECRET_NAME -R $REPO"
echo ""
