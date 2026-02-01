# TillDash Self-Hosted Mail Server

A completely **free, unlimited** mail server solution for TillDash using Docker and Postfix.

## Features

- ✅ **100% Free** - No limits on sending
- ✅ **Full Control** - Own your email infrastructure
- ✅ **SMTP/IMAP** - Standard email protocols
- ✅ **DKIM/SPF/DMARC** - Full email authentication
- ✅ **Spam Protection** - Built-in SpamAssassin
- ✅ **Webmail Interface** - Optional Roundcube UI
- ✅ **Fail2Ban** - Automatic security protection

## Quick Start

### Prerequisites

- Docker and Docker Compose installed
- A domain name (e.g., tilldash.com)
- A server with public IP address
- Port 25, 587, 465, and 993 accessible

### Installation

1. **Navigate to mail server directory**:
```bash
cd mail_server
```

2. **Configure environment**:
```bash
cp .env.example .env
nano .env  # Edit with your settings
```

Update these values:
- `MAIL_DOMAIN`: Your domain (tilldash.com)
- `MAIL_HOSTNAME`: Mail server hostname (mail.tilldash.com)
- `MAIL_ACCOUNTS`: Email accounts to create
- `SERVER_PUBLIC_IP`: Your server's public IP

3. **Run setup script**:
```bash
chmod +x setup.sh
./setup.sh
```

4. **Configure DNS records** (see [DNS-SETUP.md](DNS-SETUP.md)):
   - A record: mail.tilldash.com → SERVER_IP
   - MX record: tilldash.com → mail.tilldash.com
   - SPF, DKIM, DMARC TXT records
   - Reverse DNS (PTR) - contact your hosting provider

5. **Wait for DNS propagation** (up to 48 hours)

6. **Test email sending**:
```bash
chmod +x test-email.sh
./test-email.sh your-email@gmail.com
```

## Django Integration

Update your TillDash backend `.env` file:

```env
# Email Backend Configuration
EMAIL_BACKEND=django.core.mail.backends.smtp.EmailBackend
EMAIL_HOST=mail.tilldash.com
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_HOST_USER=support@tilldash.com
EMAIL_HOST_PASSWORD=your_password_here
DEFAULT_FROM_EMAIL=support@tilldash.com
```

Or if running mail server on same machine:
```env
EMAIL_HOST=localhost
EMAIL_PORT=587
```

## Email Account Management

```bash
chmod +x manage-accounts.sh

# Create new email account
./manage-accounts.sh add sales@tilldash.com strong_password

# Delete email account
./manage-accounts.sh del old@tilldash.com

# Update password
./manage-accounts.sh update support@tilldash.com new_password

# List all accounts
./manage-accounts.sh list
```

## Service Management

```bash
# Start mail server
docker compose up -d

# Stop mail server
docker compose down

# View logs
docker compose logs -f mailserver

# Restart mail server
docker compose restart mailserver

# Check status
docker compose ps
```

## Accessing Webmail

The webmail interface (Roundcube) is available at:
- Local: http://localhost:8080
- Remote: http://YOUR_SERVER_IP:8080

Login with any email account you created.

## Monitoring

### View Mail Queue
```bash
docker compose exec mailserver mailq
```

### Check Service Status
```bash
docker compose exec mailserver supervisorctl status
```

### View Real-time Logs
```bash
docker compose logs -f mailserver
```

### Check Postfix Configuration
```bash
docker compose exec mailserver postconf -n
```

## Troubleshooting

### Emails not sending

1. Check if mail server is running:
```bash
docker compose ps
```

2. View logs for errors:
```bash
docker compose logs mailserver
```

3. Verify port 25 is not blocked:
```bash
telnet mail.tilldash.com 25
```

4. Check mail queue:
```bash
docker compose exec mailserver mailq
```

### Emails going to spam

1. Verify all DNS records are correct:
```bash
dig MX tilldash.com
dig TXT tilldash.com  # SPF
dig TXT mail._domainkey.tilldash.com  # DKIM
dig TXT _dmarc.tilldash.com  # DMARC
```

2. Test email deliverability:
   - Visit https://www.mail-tester.com/
   - Send test email to the provided address
   - Check your score (aim for 10/10)

3. Ensure reverse DNS (PTR) is configured

### Authentication failures

1. Verify credentials:
```bash
docker compose exec mailserver setup email list
```

2. Test authentication:
```bash
./test-email.sh your@email.com
```

## Security Best Practices

1. **Use strong passwords** for email accounts
2. **Keep SSL certificates updated** (use Let's Encrypt)
3. **Enable Fail2Ban** (already configured)
4. **Monitor logs regularly** for suspicious activity
5. **Limit access** to necessary ports only
6. **Regular backups** of mail data:
```bash
tar -czf mail-backup-$(date +%Y%m%d).tar.gz docker-data/
```

## Directory Structure

```
mail_server/
├── docker-compose.yml      # Docker configuration
├── .env.example            # Environment template
├── setup.sh                # Initial setup script
├── test-email.sh           # Email testing script
├── manage-accounts.sh      # Account management
├── aws-dns-setup.sh        # AWS Route 53 setup
├── DNS-SETUP.md            # DNS configuration guide
├── README.md               # This file
└── docker-data/            # Mail server data (created on setup)
    └── dms/
        ├── mail-data/      # Email storage
        ├── mail-state/     # Server state
        ├── mail-logs/      # Log files
        └── config/         # Configuration files
            ├── ssl/        # SSL certificates
            └── opendkim/   # DKIM keys
```

## Backup and Restore

### Backup
```bash
# Stop mail server
docker compose down

# Backup all data
tar -czf mail-backup-$(date +%Y%m%d).tar.gz docker-data/

# Restart mail server
docker compose up -d
```

### Restore
```bash
# Stop mail server
docker compose down

# Extract backup
tar -xzf mail-backup-YYYYMMDD.tar.gz

# Restart mail server
docker compose up -d
```

## Upgrading

```bash
# Pull latest image
docker compose pull

# Restart with new image
docker compose up -d
```

## Cost Analysis

| Service | Cost |
|---------|------|
| Mail Server Software | **$0** (Open source) |
| Email Sending | **Unlimited** |
| Email Storage | Only server disk space |
| Domains | Your domain cost (~$10-15/year) |
| Server | Your existing server |

**Total additional cost: $0/month** 🎉

## Support

For issues or questions:
1. Check logs: `docker compose logs mailserver`
2. Review [DNS-SETUP.md](DNS-SETUP.md) for configuration
3. Test with mail-tester.com
4. Check Docker Mailserver docs: https://docker-mailserver.github.io/

## License

This configuration uses:
- [Docker Mailserver](https://github.com/docker-mailserver/docker-mailserver) (MIT License)
- [Roundcube](https://roundcube.net/) (GPL-3.0 License)
