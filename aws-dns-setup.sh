#!/bin/bash

# AWS CLI DNS Setup Script for TillDash Mail Server
# This script creates necessary DNS records in AWS Route 53

set -e

# Configuration
DOMAIN="tilldash.com"
HOSTED_ZONE_ID="YOUR_HOSTED_ZONE_ID"  # Get this from Route 53 console
SERVER_IP="YOUR_SERVER_IP"

echo "Setting up DNS records for $DOMAIN in Route 53..."

# Create a JSON file for the DNS changes
cat > /tmp/dns-changes.json <<EOF
{
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "mail.${DOMAIN}",
        "Type": "A",
        "TTL": 3600,
        "ResourceRecords": [
          {
            "Value": "${SERVER_IP}"
          }
        ]
      }
    },
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "${DOMAIN}",
        "Type": "MX",
        "TTL": 3600,
        "ResourceRecords": [
          {
            "Value": "10 mail.${DOMAIN}"
          }
        ]
      }
    },
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "${DOMAIN}",
        "Type": "TXT",
        "TTL": 3600,
        "ResourceRecords": [
          {
            "Value": "\"v=spf1 mx ip4:${SERVER_IP} ~all\""
          }
        ]
      }
    },
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "_dmarc.${DOMAIN}",
        "Type": "TXT",
        "TTL": 3600,
        "ResourceRecords": [
          {
            "Value": "\"v=DMARC1; p=quarantine; rua=mailto:postmaster@${DOMAIN}; pct=100; adkim=s; aspf=s\""
          }
        ]
      }
    }
  ]
}
EOF

# Apply the changes
echo "Creating DNS records..."
aws route53 change-resource-record-sets \
    --hosted-zone-id ${HOSTED_ZONE_ID} \
    --change-batch file:///tmp/dns-changes.json

echo "DNS records created successfully!"
echo ""
echo "Note: DKIM record must be added manually after setup:"
echo "1. Run ./setup.sh to generate DKIM keys"
echo "2. Get the DKIM public key from: docker-data/dms/config/opendkim/keys/${DOMAIN}/mail.txt"
echo "3. Add it as a TXT record: mail._domainkey.${DOMAIN}"
echo ""
echo "DNS propagation may take up to 48 hours"

# Clean up
rm /tmp/dns-changes.json
