#!/bin/bash

# Test Email Script for TillDash Mail Server
# Usage: ./test-email.sh recipient@example.com

if [ -z "$1" ]; then
    echo "Usage: ./test-email.sh recipient@example.com"
    exit 1
fi

RECIPIENT=$1
FROM_EMAIL="support@tilldash.com"
SUBJECT="Test Email from TillDash Mail Server"

echo "Sending test email to $RECIPIENT..."

docker compose exec -T mailserver swaks \
    --to "$RECIPIENT" \
    --from "$FROM_EMAIL" \
    --server localhost \
    --port 587 \
    --auth-user "$FROM_EMAIL" \
    --auth-password "$(grep 'support@tilldash.com' .env | cut -d'|' -f2)" \
    --tls \
    --header "Subject: $SUBJECT" \
    --body "This is a test email from your TillDash mail server.

If you received this email, your mail server is working correctly!

Server: mail.tilldash.com
Time: $(date)

Best regards,
TillDash Team"

echo ""
echo "Email sent! Check $RECIPIENT inbox (including spam folder)"
