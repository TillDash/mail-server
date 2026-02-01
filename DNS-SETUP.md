# DNS Configuration for TillDash Mail Server

To ensure your emails are delivered and not marked as spam, you need to configure the following DNS records.

## Prerequisites

- Your mail server public IP address
- Access to your domain's DNS management panel

## Required DNS Records

### 1. A Record
Point your mail subdomain to your server IP:

```
Type: A
Name: mail
Value: YOUR_SERVER_IP
TTL: 3600
```

### 2. MX Record
Tell other mail servers where to send emails for your domain:

```
Type: MX
Name: @
Value: mail.tilldash.com
Priority: 10
TTL: 3600
```

### 3. SPF Record
Authorize your mail server to send emails on behalf of your domain:

```
Type: TXT
Name: @
Value: v=spf1 mx ip4:YOUR_SERVER_IP ~all
TTL: 3600
```

### 4. DKIM Record
After running the setup script, get your DKIM public key:

```bash
cat docker-data/dms/config/opendkim/keys/tilldash.com/mail.txt
```

Add it as a TXT record:

```
Type: TXT
Name: mail._domainkey
Value: v=DKIM1; k=rsa; p=YOUR_DKIM_PUBLIC_KEY_HERE
TTL: 3600
```

### 5. DMARC Record
Set up email authentication policy:

```
Type: TXT
Name: _dmarc
Value: v=DMARC1; p=quarantine; rua=mailto:postmaster@tilldash.com; pct=100; adkim=s; aspf=s
TTL: 3600
```

### 6. Reverse DNS (PTR Record)
**IMPORTANT**: Contact your hosting provider to set up reverse DNS:

```
YOUR_SERVER_IP -> mail.tilldash.com
```

This is crucial for email deliverability!

## Verification

### Check DNS Propagation
```bash
# Check A record
dig mail.tilldash.com

# Check MX record
dig MX tilldash.com

# Check SPF
dig TXT tilldash.com

# Check DKIM
dig TXT mail._domainkey.tilldash.com

# Check DMARC
dig TXT _dmarc.tilldash.com
```

### Test Email Deliverability
Use these online tools:

1. **MX Toolbox**: https://mxtoolbox.com/
2. **Mail Tester**: https://www.mail-tester.com/
3. **DKIM Validator**: https://dkimvalidator.com/

## Example: AWS Route 53 Configuration

If using AWS Route 53:

```bash
# Get your hosted zone ID
aws route53 list-hosted-zones

# Create records using AWS CLI (see aws-dns-setup.sh)
```

## Example: Cloudflare Configuration

If using Cloudflare:

1. Go to DNS settings for tilldash.com
2. Add records as specified above
3. **Important**: Disable proxy (orange cloud) for mail.tilldash.com
4. Keep MX records DNS only (grey cloud)

## Firewall Configuration

Ensure these ports are open:

```bash
# For Ubuntu/Debian with ufw
sudo ufw allow 25/tcp   # SMTP
sudo ufw allow 587/tcp  # Submission (recommended)
sudo ufw allow 465/tcp  # SMTPS
sudo ufw allow 993/tcp  # IMAPS (if using webmail)

# For AWS Security Group
# Add inbound rules for ports 25, 587, 465, 993
```

## Common Issues

### Emails go to spam
- Verify all DNS records are correct
- Ensure reverse DNS (PTR) is configured
- Use mail-tester.com to check your score
- Warm up your IP by sending gradually increasing volumes

### Cannot send emails
- Check firewall rules
- Verify port 25 is not blocked by your ISP/hosting provider
- Check logs: `docker compose logs mailserver`

### Authentication failures
- Verify credentials in .env file
- Check that email accounts were created successfully
- Test with: `docker compose exec mailserver setup email list`

## Testing

After DNS propagation (can take up to 48 hours):

```bash
# Send test email
./test-email.sh your-email@gmail.com
```

## Monitoring

Check mail server status:

```bash
# View logs
docker compose logs -f mailserver

# Check running processes
docker compose exec mailserver supervisorctl status

# View mail queue
docker compose exec mailserver mailq
```
