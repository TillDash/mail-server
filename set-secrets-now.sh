#!/bin/bash

# Quick GitHub Secrets Setup for TillDash Mail Server
# Sets all secrets with sensible defaults

REPO="tilldash/mail-server"

echo "Setting GitHub secrets for $REPO..."
echo ""

# Core mail server settings
gh secret set MAIL_DOMAIN -b "tilldash.com" -R $REPO
echo "✓ MAIL_DOMAIN = tilldash.com"

gh secret set MAIL_HOSTNAME -b "mail.tilldash.com" -R $REPO
echo "✓ MAIL_HOSTNAME = mail.tilldash.com"

# Email accounts (change passwords before deploying!)
gh secret set MAIL_ACCOUNTS -b "support@tilldash.com|TillDash2026Support!,noreply@tilldash.com|TillDash2026NoReply!,sales@tilldash.com|TillDash2026Sales!" -R $REPO
echo "✓ MAIL_ACCOUNTS = support, noreply, sales @tilldash.com"

# SSL Configuration
gh secret set SSL_TYPE -b "manual" -R $REPO
echo "✓ SSL_TYPE = manual"

gh secret set LETSENCRYPT_EMAIL -b "admin@tilldash.com" -R $REPO
echo "✓ LETSENCRYPT_EMAIL = admin@tilldash.com"

gh secret set LETSENCRYPT_HOST -b "mail.tilldash.com" -R $REPO
echo "✓ LETSENCRYPT_HOST = mail.tilldash.com"

# Server settings (placeholders - update these!)
gh secret set SERVER_PUBLIC_IP -b "YOUR_SERVER_IP_HERE" -R $REPO
echo "✓ SERVER_PUBLIC_IP = (placeholder - UPDATE THIS)"

gh secret set EC2_PUBLIC_IP -b "YOUR_EC2_IP_HERE" -R $REPO
echo "✓ EC2_PUBLIC_IP = (placeholder - UPDATE THIS)"

gh secret set EC2_SSH_PRIVATE_KEY -b "YOUR_SSH_KEY_HERE" -R $REPO
echo "✓ EC2_SSH_PRIVATE_KEY = (placeholder - UPDATE THIS)"

# Performance settings
gh secret set ENABLE_FAIL2BAN -b "1" -R $REPO
echo "✓ ENABLE_FAIL2BAN = 1"

gh secret set ENABLE_SPAMASSASSIN -b "1" -R $REPO
echo "✓ ENABLE_SPAMASSASSIN = 1"

gh secret set ENABLE_CLAMAV -b "0" -R $REPO
echo "✓ ENABLE_CLAMAV = 0 (disabled for performance)"

gh secret set POSTFIX_MESSAGE_SIZE_LIMIT -b "51200000" -R $REPO
echo "✓ POSTFIX_MESSAGE_SIZE_LIMIT = 50MB"

echo ""
echo "========================================="
echo "✓ All secrets set successfully!"
echo "========================================="
echo ""
echo "⚠️  IMPORTANT: Update these secrets before deploying:"
echo "  - SERVER_PUBLIC_IP (your server's public IP)"
echo "  - EC2_PUBLIC_IP (your EC2 instance IP)"
echo "  - EC2_SSH_PRIVATE_KEY (your SSH private key)"
echo "  - MAIL_ACCOUNTS passwords (use strong passwords!)"
echo ""
echo "Update a secret:"
echo "  gh secret set SECRET_NAME -b 'new_value' -R $REPO"
echo ""
echo "View all secrets:"
echo "  gh secret list -R $REPO"
echo ""
echo "Repository: https://github.com/$REPO"
echo "Secrets: https://github.com/$REPO/settings/secrets/actions"
echo ""
