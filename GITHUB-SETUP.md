# Mail Server GitHub Setup

This repository is configured to use **GitHub Secrets** for secure environment variable management and **GitHub Actions** for automated deployment.

## 🔐 Setup GitHub Secrets

### Automated Setup

Run the setup script:

```bash
./setup-github-secrets.sh
```

This will prompt you for all required values and automatically set them as GitHub secrets.

### Manual Setup

Alternatively, go to: `https://github.com/tilldash/mail-server/settings/secrets/actions`

Add these secrets:

#### Required Secrets

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `MAIL_DOMAIN` | Your domain name | `tilldash.com` |
| `MAIL_HOSTNAME` | Mail server hostname | `mail.tilldash.com` |
| `SERVER_PUBLIC_IP` | Server's public IP | `54.123.45.67` |
| `MAIL_ACCOUNTS` | Email accounts (email\|password pairs, comma-separated) | `support@tilldash.com\|pass1,sales@tilldash.com\|pass2` |
| `EC2_PUBLIC_IP` | EC2 instance public IP | `54.123.45.67` |
| `EC2_SSH_PRIVATE_KEY` | SSH private key for EC2 | `-----BEGIN RSA PRIVATE KEY-----...` |

#### SSL Configuration Secrets

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `SSL_TYPE` | SSL certificate type | `manual` or `letsencrypt` |
| `LETSENCRYPT_EMAIL` | Email for Let's Encrypt (if using) | `admin@tilldash.com` |
| `LETSENCRYPT_HOST` | Hostname for Let's Encrypt | `mail.tilldash.com` |

#### Optional AWS Secrets (for DNS automation)

| Secret Name | Description |
|-------------|-------------|
| `AWS_ACCESS_KEY_ID` | AWS access key |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key |
| `AWS_HOSTED_ZONE_ID` | Route 53 hosted zone ID |

## 🚀 Deployment

### Automatic Deployment

Deployment happens automatically on push to `main` branch:

```bash
git add .
git commit -m "Deploy mail server"
git push origin main
```

Watch the deployment: https://github.com/tilldash/mail-server/actions

### Manual Deployment

Trigger deployment manually:

1. Go to: https://github.com/tilldash/mail-server/actions
2. Select "Deploy Mail Server" workflow
3. Click "Run workflow"

## 📋 Pre-Deployment Checklist

Before deploying, ensure:

- [ ] All GitHub secrets are set
- [ ] EC2 instance is running
- [ ] Security group allows ports: 25, 587, 465, 993
- [ ] SSH key has correct permissions
- [ ] Domain DNS is accessible
- [ ] Reverse DNS (PTR) is configured or requested

## 🔄 Workflow Details

### Deploy Workflow

Located at: `.github/workflows/deploy.yml`

**What it does:**
1. Creates `.env` from GitHub secrets
2. Installs Docker on EC2 (if needed)
3. Copies files to server
4. Runs setup script
5. Configures DNS (if AWS credentials provided)
6. Displays next steps

**Triggers:**
- Push to `main` branch
- Manual trigger

### Test Workflow

Located at: `.github/workflows/test.yml`

**What it does:**
1. Validates Docker Compose configuration
2. Checks shell script syntax
3. Verifies environment template
4. Validates documentation files

**Triggers:**
- Pull requests to `main`
- Manual trigger

## 📝 Managing Secrets

### View all secrets
```bash
gh secret list -R tilldash/mail-server
```

### Update a secret
```bash
gh secret set SECRET_NAME -R tilldash/mail-server
```

Example:
```bash
# Update mail accounts
gh secret set MAIL_ACCOUNTS -b "support@tilldash.com|newpass,sales@tilldash.com|pass2" -R tilldash/mail-server

# Update server IP
gh secret set SERVER_PUBLIC_IP -b "54.123.45.67" -R tilldash/mail-server
```

### Delete a secret
```bash
gh secret delete SECRET_NAME -R tilldash/mail-server
```

## 🔍 Monitoring Deployments

### View deployment logs
```bash
gh run list -R tilldash/mail-server
gh run view [RUN_ID] -R tilldash/mail-server
```

### Check deployment status
```bash
gh run watch -R tilldash/mail-server
```

### View workflow runs
https://github.com/tilldash/mail-server/actions

## 🛠️ Post-Deployment

After successful deployment:

1. **Get DKIM Key:**
```bash
ssh ubuntu@YOUR_SERVER_IP 'cat ~/mail-server/docker-data/dms/config/opendkim/keys/tilldash.com/mail.txt'
```

2. **Add DKIM DNS Record:**
   - Name: `mail._domainkey.tilldash.com`
   - Type: `TXT`
   - Value: [DKIM key from step 1]

3. **Test Email:**
```bash
ssh ubuntu@YOUR_SERVER_IP 'cd ~/mail-server && ./test-email.sh your@email.com'
```

4. **Update Backend:**
   - Update TillDash-backend repository secrets
   - Set EMAIL_HOST to your mail server hostname

## 🔒 Security Best Practices

1. **Never commit secrets** to the repository
2. **Use strong passwords** for email accounts
3. **Rotate SSH keys** regularly
4. **Monitor access logs** in GitHub
5. **Enable 2FA** on GitHub account
6. **Review secrets** periodically

## 🐛 Troubleshooting

### Deployment fails

1. Check workflow logs:
```bash
gh run list -R tilldash/mail-server --limit 1
gh run view --log
```

2. Verify secrets are set:
```bash
gh secret list -R tilldash/mail-server
```

3. Test SSH connection:
```bash
ssh -i ~/.ssh/your_key ubuntu@YOUR_SERVER_IP
```

### Secrets not updating

1. Delete and recreate:
```bash
gh secret delete SECRET_NAME -R tilldash/mail-server
gh secret set SECRET_NAME -R tilldash/mail-server
```

2. Verify secret was set:
```bash
gh secret list -R tilldash/mail-server | grep SECRET_NAME
```

## 📚 Resources

- [GitHub Secrets Documentation](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [GitHub CLI Documentation](https://cli.github.com/manual/)

## 🎯 Next Steps

1. Run setup script: `./setup-github-secrets.sh`
2. Push code to repository
3. Monitor deployment in GitHub Actions
4. Configure DNS records
5. Test email sending
6. Integrate with TillDash backend

For detailed deployment instructions, see [QUICKSTART.md](QUICKSTART.md)
