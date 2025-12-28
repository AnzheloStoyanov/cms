# Hostinger Deployment Quick Start

This is a quick reference guide for deploying your Strapi CMS to Hostinger. For detailed instructions, see [DEPLOYMENT.md](./DEPLOYMENT.md).

## Prerequisites Checklist

- [ ] Hostinger VPS or Business hosting account
- [ ] SSH access enabled
- [ ] Node.js 20.x or higher
- [ ] MySQL database created in hPanel
- [ ] Domain configured and pointing to your server

## 5-Minute Deployment

### 1. Connect via SSH
```bash
ssh your-username@your-server-ip
```

### 2. Navigate to your web directory
```bash
cd ~/public_html
```

### 3. Clone the repository (or upload via FTP)
```bash
git clone https://github.com/AnzheloStoyanov/cms.git
cd cms
```

### 4. Create environment configuration
```bash
cp .env.production .env
nano .env
```

Update these critical values:
- `APP_KEYS` - Generate 4 random secure keys
- `DATABASE_NAME` - Your Hostinger MySQL database name
- `DATABASE_USERNAME` - Your database username
- `DATABASE_PASSWORD` - Your database password
- `URL` - Your domain (e.g., https://yourdomain.com)

**Generate secure keys:**
```bash
node -e "console.log(require('crypto').randomBytes(32).toString('base64'))"
```

### 5. Install PM2 globally (if not installed)
```bash
npm install -g pm2
```

### 6. Run deployment script
```bash
chmod +x deploy.sh
./deploy.sh
```

### 7. Set up PM2 to start on reboot
```bash
pm2 startup
pm2 save
```

### 8. Configure domain in hPanel

1. Go to hPanel → Advanced → Node.js
2. Create Node.js application:
   - Application root: `/public_html/cms`
   - Application startup file: `node_modules/.bin/strapi`
   - Application startup command: `start`
   - Port: 1337

Alternatively, configure Apache proxy using the `.htaccess` file (already included).

### 9. Enable SSL

In hPanel:
1. Go to SSL section
2. Select your domain
3. Install SSL certificate (Free Let's Encrypt)

### 10. Access your CMS

- Admin: `https://yourdomain.com/admin`
- API: `https://yourdomain.com/api`

Create your first admin user when prompted!

## Common Issues

### Port already in use
```bash
# Find process using port 1337
lsof -i :1337
# Kill it if needed
kill -9 <PID>
# Or change PORT in .env file
```

### Database connection failed
- Verify credentials in `.env`
- Check database host (usually `localhost` on Hostinger)
- Ensure database exists in hPanel

### Permission denied
```bash
chmod -R 755 ~/public_html/cms
chown -R $USER:$USER ~/public_html/cms
```

### Application crashes
```bash
# Check logs
pm2 logs cms

# Restart application
pm2 restart cms

# Check system resources
pm2 monit
```

## Update Application

```bash
cd ~/public_html/cms
./deploy.sh
```

## Useful Commands

```bash
# View logs
pm2 logs cms

# Monitor application
pm2 monit

# Restart
pm2 restart cms

# Stop
pm2 stop cms

# Application status
pm2 list
```

## Need Help?

- 📖 Full deployment guide: [DEPLOYMENT.md](./DEPLOYMENT.md)
- 🌐 Strapi docs: https://docs.strapi.io
- 💬 Hostinger support: https://www.hostinger.com/support

## Production Security Checklist

After deployment, ensure:
- ✅ All secret keys are unique and secure
- ✅ SSL/HTTPS is enabled
- ✅ Database credentials are secure
- ✅ `.env` file is not publicly accessible
- ✅ Regular backups are configured
- ✅ Firewall rules are configured
- ✅ Admin panel access is restricted (if needed)
