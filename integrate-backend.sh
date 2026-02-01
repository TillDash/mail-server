#!/bin/bash

# Integration Script - Connect Django Backend to Mail Server
# This script helps configure the Django backend to use the self-hosted mail server

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}TillDash Mail Server Integration${NC}"
echo "================================="
echo ""

# Check if we're in the backend directory
if [ ! -f "manage.py" ]; then
    echo -e "${YELLOW}Please run this script from the TillDash-backend directory${NC}"
    exit 1
fi

# Get mail server details
read -p "Mail server hostname (e.g., mail.tilldash.com or localhost): " MAIL_HOST
read -p "SMTP port [587]: " MAIL_PORT
MAIL_PORT=${MAIL_PORT:-587}

read -p "Email address (e.g., support@tilldash.com): " EMAIL_USER
read -sp "Email password: " EMAIL_PASS
echo ""

# Update .env file
if [ -f ".env" ]; then
    echo -e "${GREEN}Updating .env file...${NC}"
    
    # Backup existing .env
    cp .env .env.backup.$(date +%Y%m%d_%H%M%S)
    
    # Update or add email settings
    if grep -q "EMAIL_HOST=" .env; then
        sed -i.bak "s|^EMAIL_HOST=.*|EMAIL_HOST=${MAIL_HOST}|" .env
        sed -i.bak "s|^EMAIL_PORT=.*|EMAIL_PORT=${MAIL_PORT}|" .env
        sed -i.bak "s|^EMAIL_HOST_USER=.*|EMAIL_HOST_USER=${EMAIL_USER}|" .env
        sed -i.bak "s|^EMAIL_HOST_PASSWORD=.*|EMAIL_HOST_PASSWORD=${EMAIL_PASS}|" .env
        sed -i.bak "s|^DEFAULT_FROM_EMAIL=.*|DEFAULT_FROM_EMAIL=${EMAIL_USER}|" .env
    else
        cat >> .env <<EOF

# Self-hosted Mail Server Configuration
EMAIL_BACKEND=django.core.mail.backends.smtp.EmailBackend
EMAIL_HOST=${MAIL_HOST}
EMAIL_PORT=${MAIL_PORT}
EMAIL_USE_TLS=True
EMAIL_HOST_USER=${EMAIL_USER}
EMAIL_HOST_PASSWORD=${EMAIL_PASS}
DEFAULT_FROM_EMAIL=${EMAIL_USER}
EOF
    fi
    
    rm -f .env.bak
    echo -e "${GREEN}✓ .env file updated${NC}"
else
    echo -e "${YELLOW}No .env file found. Creating from .env.example...${NC}"
    cp .env.example .env
    
    # Add email configuration
    cat >> .env <<EOF

# Self-hosted Mail Server Configuration
EMAIL_BACKEND=django.core.mail.backends.smtp.EmailBackend
EMAIL_HOST=${MAIL_HOST}
EMAIL_PORT=${MAIL_PORT}
EMAIL_USE_TLS=True
EMAIL_HOST_USER=${EMAIL_USER}
EMAIL_HOST_PASSWORD=${EMAIL_PASS}
DEFAULT_FROM_EMAIL=${EMAIL_USER}
EOF
    
    echo -e "${GREEN}✓ .env file created${NC}"
fi

# Test email configuration
echo ""
echo -e "${GREEN}Testing email configuration...${NC}"

python3 << 'PYTHON_SCRIPT'
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'TillDash_backend.settings')
django.setup()

from django.core.mail import send_mail
from django.conf import settings

print(f"\nEmail Configuration:")
print(f"  Backend: {settings.EMAIL_BACKEND}")
print(f"  Host: {settings.EMAIL_HOST}:{settings.EMAIL_PORT}")
print(f"  From: {settings.DEFAULT_FROM_EMAIL}")
print(f"  TLS: {settings.EMAIL_USE_TLS}")

# Ask for test email
test_email = input("\nEnter email address to send test email (or press Enter to skip): ")

if test_email:
    try:
        send_mail(
            subject='TillDash Mail Server Test',
            message='This is a test email from your TillDash backend.\n\nIf you received this, your integration is working correctly!',
            from_email=settings.DEFAULT_FROM_EMAIL,
            recipient_list=[test_email],
            fail_silently=False,
        )
        print(f"\n✓ Test email sent to {test_email}")
        print("  Check your inbox (and spam folder)")
    except Exception as e:
        print(f"\n✗ Error sending test email: {e}")
        print("\nTroubleshooting:")
        print("1. Ensure mail server is running: cd ../mail_server && docker compose ps")
        print("2. Check mail server logs: cd ../mail_server && docker compose logs mailserver")
        print("3. Verify email account exists: cd ../mail_server && ./manage-accounts.sh list")
else:
    print("\nSkipping test email")
PYTHON_SCRIPT

echo ""
echo -e "${GREEN}=================================${NC}"
echo -e "${GREEN}Integration Complete!${NC}"
echo -e "${GREEN}=================================${NC}"
echo ""
echo "Your Django backend is now configured to use the self-hosted mail server."
echo ""
echo "Next steps:"
echo "1. Ensure mail server is running: cd ../mail_server && docker compose ps"
echo "2. Test sending emails from your application"
echo "3. Monitor mail logs: cd ../mail_server && docker compose logs -f mailserver"
echo ""
