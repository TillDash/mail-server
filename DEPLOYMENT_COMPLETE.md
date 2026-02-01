# Mail Server Deployment - COMPLETE ✅

## 🎉 Deployment Status

**Mail server successfully deployed to production!**

- **Server**: 54.74.205.65 (tilldash-prod)
- **Hostname**: mail.tilldash.com
- **Domain**: tilldash.com
- **Status**: ✅ HEALTHY and RUNNING

## 📧 Email Accounts Created

| Email | Status |
|-------|--------|
| support@tilldash.com | ✅ Active |
| noreply@tilldash.com | ✅ Active |
| sales@tilldash.com | ✅ Active |

## 🔐 Access Information

### SSH Access
```bash
ssh -i tilldash-mail-server-key.pem ubuntu@54.74.205.65
cd ~/mail-server
```

### Webmail Access
- **URL**: http://54.74.205.65:8080
- **After DNS**: http://mail.tilldash.com:8080
- Use any email account above with its password

### SMTP Settings (for TillDash Backend)
```env
EMAIL_HOST=mail.tilldash.com
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_HOST_USER=noreply@tilldash.com
EMAIL_HOST_PASSWORD=TillDash2026NoReply!
DEFAULT_FROM_EMAIL=noreply@tilldash.com
```

## 📋 Required DNS Configuration

To make the mail server fully operational, configure these DNS records in your domain registrar:

### 1. A Record (Point domain to server)
```
Type: A
Name: mail.tilldash.com
Value: 54.74.205.65
TTL: 300
```

### 2. MX Record (Mail exchanger)
```
Type: MX
Name: tilldash.com
Value: mail.tilldash.com
Priority: 10
TTL: 300
```

### 3. SPF Record (Sender Policy Framework)
```
Type: TXT
Name: tilldash.com
Value: v=spf1 mx a:mail.tilldash.com ip4:54.74.205.65 ~all
TTL: 300
```

### 4. DKIM Record (DomainKeys Identified Mail)
```
Type: TXT
Name: mail._domainkey.tilldash.com
Value: v=DKIM1; h=sha256; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAr3OwMoU8D1sPImX6WDAEZlB/P8gGrOLC62qi2aXtttz1A4dq7NXsRIZUlbrOmqZKgBIYwJm9vjnGVG/QlkYhvO8FZnK5AlA95yiGNWahT8HtG1ztMTta/OBrOW87kImwDExL1GQ+ajaVNqwrKvqrD1cPm4LYXFRmqt1DeRpgjnlUkXD98wsR1fBADfOEyt/7JEGVKcCduCVbgXC+YuevWFrPyeBRmYN+vlqjlevmP+7aYEZL0+Txlr/1fHxtJ7cQ+0gxdGeJE0XwUs+q6oAJtfBwxREQyPiBKZtUMaMgHMi/a+zEj913QuHPjvEsrerC+U15cf116B5cHJ1GhW0s1QIDAQAB
TTL: 300
```

### 5. DMARC Record (Domain-based Message Authentication)
```
Type: TXT
Name: _dmarc.tilldash.com
Value: v=DMARC1; p=quarantine; rua=mailto:postmaster@tilldash.com; pct=100; adkim=s; aspf=s
TTL: 300
```

### 6. Reverse DNS (PTR Record)
**Important**: Contact AWS support to set up reverse DNS:
- PTR: 54.74.205.65 → mail.tilldash.com

This prevents emails from being marked as spam.

## 🔧 Management Commands

### View logs
```bash
ssh -i tilldash-mail-server-key.pem ubuntu@54.74.205.65
cd ~/mail-server
docker compose logs -f mailserver
```

### Add new email account
```bash
sudo docker exec tilldash-mailserver setup email add user@tilldash.com "Password123!"
```

### List all accounts
```bash
sudo docker exec tilldash-mailserver setup email list
```

### Delete account
```bash
sudo docker exec tilldash-mailserver setup email del user@tilldash.com
```

### Change password
```bash
sudo docker exec tilldash-mailserver setup email update user@tilldash.com "NewPassword123!"
```

### Restart mail server
```bash
cd ~/mail-server
docker compose restart mailserver
```

### Check DKIM configuration
```bash
sudo docker exec tilldash-mailserver setup config dkim
sudo cat ~/mail-server/docker-data/dms/config/opendkim/keys/tilldash.com/mail.txt
```

## ✅ Next Steps

1. **Configure DNS Records** (See above) - CRITICAL for email delivery
2. **Set up Reverse DNS** with AWS support
3. **Test Email Sending** after DNS propagation (24-48 hours)
4. **Update TillDash Backend** with SMTP settings
5. **Configure Firewall** (if needed):
   ```bash
   # Allow mail ports
   sudo ufw allow 25/tcp
   sudo ufw allow 587/tcp
   sudo ufw allow 465/tcp
   sudo ufw allow 993/tcp
   sudo ufw allow 8080/tcp
   ```

## 🧪 Testing Email

After DNS is configured, test sending email:

```bash
ssh -i tilldash-mail-server-key.pem ubuntu@54.74.205.65
cd ~/mail-server
./test-email.sh
```

Or send test email manually:
```bash
sudo docker exec tilldash-mailserver setup debug send-email \
  --from noreply@tilldash.com \
  --to your-email@gmail.com \
  --subject "Test from TillDash Mail Server" \
  --body "This is a test email"
```

## 📊 Monitoring

### Check container status
```bash
cd ~/mail-server
docker compose ps
```

### Check server health
```bash
sudo docker exec tilldash-mailserver setup config check
```

### View mail queue
```bash
sudo docker exec tilldash-mailserver postqueue -p
```

## 🔒 Security Features Enabled

- ✅ DKIM signing
- ✅ SPF validation
- ✅ DMARC policy
- ✅ Fail2Ban protection
- ✅ SSL/TLS encryption (self-signed, upgrade to Let's Encrypt after DNS)
- ✅ SpamAssassin filtering
- ✅ Authentication required for sending

## 📚 Documentation

- Main README: [README.md](README.md)
- Quick Start: [QUICKSTART.md](QUICKSTART.md)
- DNS Setup: [DNS-SETUP.md](DNS-SETUP.md)
- GitHub Setup: [GITHUB-SETUP.md](GITHUB-SETUP.md)

## 🎯 Current Limitations

1. **No DNS records configured** - Emails will not be deliverable until DNS is set up
2. **Self-signed SSL** - After DNS is configured, switch to Let's Encrypt:
   ```bash
   # In .env file, change:
   SSL_TYPE=letsencrypt
   # Then restart:
   docker compose down && docker compose up -d
   ```
3. **No reverse DNS** - Some mail servers may reject emails without PTR record

## 💰 Cost Analysis

**Total Monthly Cost: $0** ✅

- Self-hosted on existing EC2 instance (no additional cost)
- No SendGrid fees
- No AWS SES fees
- Unlimited email sending

## 🆘 Troubleshooting

### Mail server not starting
```bash
docker compose logs mailserver
docker compose restart mailserver
```

### Emails not sending
1. Check DNS records are configured
2. Check logs: `docker compose logs -f mailserver`
3. Verify reverse DNS is set up
4. Check firewall allows ports 25, 587, 465

### Can't login to webmail
1. Check container is running: `docker compose ps`
2. Verify account exists: `sudo docker exec tilldash-mailserver setup email list`
3. Reset password: `sudo docker exec tilldash-mailserver setup email update user@tilldash.com "NewPass123!"`

---

**Deployment completed**: February 1, 2026
**Deployed by**: GitHub Actions
**Repository**: https://github.com/TillDash/mail-server
