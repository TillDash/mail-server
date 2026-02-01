# TillDash Mail Server - Quick Start Guide

## 🎯 What You Get

A **completely FREE** mail server with **UNLIMITED** sending capacity. No monthly fees, no sending limits!

## 📋 Prerequisites

- Domain name (e.g., tilldash.com)
- Server with public IP
- Docker & Docker Compose installed
- Ports 25, 587, 465, 993 open

## 🚀 5-Minute Setup

### Step 1: Configure Environment

```bash
cd mail_server
cp .env.example .env
nano .env
```

Update these values:
- `MAIL_DOMAIN=tilldash.com`
- `SERVER_PUBLIC_IP=your.server.ip`
- `MAIL_ACCOUNTS=support@tilldash.com|StrongPassword123`

### Step 2: Run Setup

```bash
./setup.sh
```

This will:
- Create directory structure
- Generate SSL certificates
- Start mail server
- Create email accounts
- Generate DKIM keys

### Step 3: Configure DNS

Add these records to your domain DNS:

```
# A Record
mail.tilldash.com → YOUR_SERVER_IP

# MX Record
tilldash.com → mail.tilldash.com (priority 10)

# SPF Record
tilldash.com TXT "v=spf1 mx ip4:YOUR_SERVER_IP ~all"

# DMARC Record
_dmarc.tilldash.com TXT "v=DMARC1; p=quarantine; rua=mailto:postmaster@tilldash.com"
```

Get your DKIM record:
```bash
cat docker-data/dms/config/opendkim/keys/tilldash.com/mail.txt
```

Add as:
```
mail._domainkey.tilldash.com TXT "v=DKIM1; k=rsa; p=YOUR_DKIM_KEY_HERE"
```

**Important:** Contact your hosting provider to set up **Reverse DNS (PTR)**:
```
YOUR_SERVER_IP → mail.tilldash.com
```

### Step 4: Wait for DNS Propagation

DNS changes can take up to 48 hours. Check progress:

```bash
dig mail.tilldash.com  # Should show your IP
dig MX tilldash.com    # Should show mail.tilldash.com
```

### Step 5: Test Email

```bash
./test-email.sh youremail@gmail.com
```

Check your inbox (and spam folder)!

## 🔗 Integrate with Django

```bash
./integrate-backend.sh
```

Or manually add to `TillDash-backend/.env`:

```env
EMAIL_BACKEND=django.core.mail.backends.smtp.EmailBackend
EMAIL_HOST=mail.tilldash.com
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_HOST_USER=support@tilldash.com
EMAIL_HOST_PASSWORD=StrongPassword123
DEFAULT_FROM_EMAIL=support@tilldash.com
```

If mail server is on same machine as backend:
```env
EMAIL_HOST=localhost
```

## 📧 Manage Email Accounts

```bash
# Create new account
./manage-accounts.sh add sales@tilldash.com SecurePass456

# List all accounts
./manage-accounts.sh list

# Update password
./manage-accounts.sh update sales@tilldash.com NewPassword789

# Delete account
./manage-accounts.sh del old@tilldash.com
```

## 🎛️ Service Control

```bash
# Start
docker compose up -d

# Stop
docker compose down

# Restart
docker compose restart mailserver

# View logs
docker compose logs -f mailserver

# Check status
docker compose ps
```

## 🌐 Webmail Access

Access Roundcube at: **http://YOUR_SERVER_IP:8080**

Login with any email account you created.

## 🔍 Monitoring

```bash
# View mail queue
docker compose exec mailserver mailq

# Check service status
docker compose exec mailserver supervisorctl status

# Real-time logs
docker compose logs -f mailserver
```

## 🛠️ Troubleshooting

### Emails not sending?

1. Check if server is running:
```bash
docker compose ps
```

2. View logs:
```bash
docker compose logs mailserver
```

3. Verify port 25 is open:
```bash
telnet mail.tilldash.com 25
```

### Emails going to spam?

1. Test your configuration: https://www.mail-tester.com/
2. Verify all DNS records are correct
3. Ensure reverse DNS (PTR) is configured
4. Check DKIM signature is valid

### Can't connect to SMTP?

1. Verify firewall allows ports 25, 587, 465
2. Check if ISP blocks port 25 (common)
3. Use port 587 instead
4. Test connection:
```bash
telnet mail.tilldash.com 587
```

## 📊 Performance Tips

### For High Volume Sending

Edit `docker-compose.yml`:

```yaml
environment:
  - POSTFIX_MESSAGE_SIZE_LIMIT=51200000
  - ENABLE_CLAMAV=0  # Disable antivirus for speed
  - ENABLE_SPAMASSASSIN=0  # Disable for outgoing-only
```

### Backup Strategy

```bash
# Daily backup
0 2 * * * cd /path/to/mail_server && tar -czf backup-$(date +\%Y\%m\%d).tar.gz docker-data/
```

## 📱 AWS Deployment

If deploying on AWS EC2:

1. **Security Group**: Allow ports 25, 587, 465, 993
2. **Elastic IP**: Assign static IP
3. **Request Throttle Removal**: AWS blocks port 25 by default
   - Go to AWS Support
   - Request removal of EC2 sending limitations

```bash
# Use AWS DNS setup script
./aws-dns-setup.sh
```

## 💰 Cost Comparison

| Service | Monthly Cost | Sending Limit |
|---------|--------------|---------------|
| SendGrid Free | $0 | 100 emails/day |
| Mailgun Free | $0 | 5,000 emails/month |
| AWS SES | $0.10/1000 | 62,000/month free from EC2 |
| **Self-hosted** | **$0** | **Unlimited** ✅ |

## 🎓 Learn More

- Full documentation: [README.md](README.md)
- DNS setup: [DNS-SETUP.md](DNS-SETUP.md)
- Docker Mailserver: https://docker-mailserver.github.io/

## ✅ Checklist

- [ ] Domain name configured
- [ ] Server with public IP
- [ ] Docker installed
- [ ] Ports open (25, 587, 465, 993)
- [ ] `.env` file configured
- [ ] `./setup.sh` executed
- [ ] DNS records added (A, MX, SPF, DKIM, DMARC)
- [ ] Reverse DNS (PTR) configured
- [ ] Test email sent successfully
- [ ] Django backend integrated
- [ ] Mail-tester.com score > 8/10

## 🎉 You're Done!

You now have a free, unlimited mail server for TillDash!

Questions? Check the troubleshooting section or review the logs.

Happy sending! 📧
