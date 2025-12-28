# Deploying Strapi CMS to Hostinger

This guide provides step-by-step instructions for deploying this Strapi CMS application to Hostinger hosting.

## Prerequisites

- Hostinger VPS or Business hosting plan with Node.js support
- SSH access to your Hostinger server
- Node.js 20.x or higher installed on the server
- MySQL or PostgreSQL database (recommended for production)

## Step 1: Prepare Your Hostinger Environment

### 1.1 SSH into Your Hostinger Server

```bash
ssh username@your-server-ip
```

### 1.2 Install Node.js (if not already installed)

Hostinger typically has Node.js pre-installed. Check the version:

```bash
node --version
npm --version
```

If you need to install or update Node.js, use nvm:

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.bashrc
nvm install 20
nvm use 20
```

### 1.3 Install PM2 for Process Management

```bash
npm install -g pm2
```

## Step 2: Set Up Your Database

### For MySQL (Recommended for Hostinger):

1. Log in to your Hostinger control panel (hPanel)
2. Navigate to "Databases" → "MySQL Databases"
3. Create a new database and user
4. Note down the database credentials:
   - Database name
   - Database username
   - Database password
   - Database host (usually localhost or specific host provided by Hostinger)

## Step 3: Upload Your Application

### Option A: Using Git (Recommended)

```bash
cd ~/public_html  # or your desired directory
git clone https://github.com/AnzheloStoyanov/cms.git
cd cms
```

### Option B: Using FTP/SFTP

Upload all project files to your hosting directory (e.g., `~/public_html/cms`)

## Step 4: Configure Environment Variables

Create a `.env` file in your project root:

```bash
cd ~/public_html/cms
nano .env
```

Add the following configuration (adjust values according to your setup):

```env
# Server Configuration
HOST=0.0.0.0
PORT=1337
NODE_ENV=production

# Security Keys (Generate secure random strings)
APP_KEYS="key1,key2,key3,key4"
API_TOKEN_SALT=your-api-token-salt
ADMIN_JWT_SECRET=your-admin-jwt-secret
TRANSFER_TOKEN_SALT=your-transfer-token-salt
JWT_SECRET=your-jwt-secret
ENCRYPTION_KEY=your-encryption-key

# Database Configuration (MySQL)
DATABASE_CLIENT=mysql
DATABASE_HOST=localhost
DATABASE_PORT=3306
DATABASE_NAME=your_database_name
DATABASE_USERNAME=your_database_user
DATABASE_PASSWORD=your_database_password
DATABASE_SSL=false

# Public URL
URL=https://yourdomain.com
```

**Important:** Generate secure random strings for all secret keys. You can use:

```bash
node -e "console.log(require('crypto').randomBytes(32).toString('base64'))"
```

## Step 5: Install Dependencies and Build

```bash
cd ~/public_html/cms
npm install --production
npm run build
```

## Step 6: Start the Application with PM2

```bash
pm2 start ecosystem.config.js --env production
pm2 save
pm2 startup
```

Follow the instructions provided by `pm2 startup` to enable automatic startup on server reboot.

## Step 7: Configure Reverse Proxy

### If Using Apache (Hostinger default):

Enable required Apache modules (if you have access):

```bash
# These may require root access or contact Hostinger support
a2enmod proxy
a2enmod proxy_http
a2enmod rewrite
```

Create or update `.htaccess` in your public directory:

```apache
RewriteEngine On
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^(.*)$ http://localhost:1337/$1 [P,L]
```

### If Using Nginx:

Add this to your Nginx site configuration:

```nginx
server {
    listen 80;
    server_name yourdomain.com;

    location / {
        proxy_pass http://localhost:1337;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## Step 8: Set Up SSL Certificate

Use Hostinger's built-in SSL or Let's Encrypt:

1. In hPanel, go to "SSL" section
2. Select your domain
3. Install SSL certificate

## Step 9: Access Your Strapi Admin

Navigate to:
- Admin panel: `https://yourdomain.com/admin`
- API: `https://yourdomain.com/api`

Create your first admin user when prompted.

## Updating Your Application

To update your application after making changes:

```bash
cd ~/public_html/cms
git pull  # if using git
npm install --production
npm run build
pm2 restart cms
```

Or use the deployment script:

```bash
chmod +x deploy.sh
./deploy.sh
```

## Useful PM2 Commands

```bash
pm2 list                 # List all running applications
pm2 logs cms            # View application logs
pm2 restart cms         # Restart the application
pm2 stop cms            # Stop the application
pm2 delete cms          # Remove the application from PM2
pm2 monit               # Monitor CPU/memory usage
```

## Troubleshooting

### Port Already in Use

If port 1337 is in use, change the `PORT` in your `.env` file and restart:

```bash
pm2 restart cms
```

### Database Connection Issues

- Verify database credentials in `.env`
- Check if MySQL is running: `systemctl status mysql`
- Verify database exists: `mysql -u username -p`

### Permission Issues

```bash
chmod -R 755 ~/public_html/cms
chown -R $USER:$USER ~/public_html/cms
```

### Out of Memory

Increase PM2 memory limit:

```bash
pm2 delete cms
pm2 start ecosystem.config.js --env production --max-memory-restart 512M
```

## Performance Optimization

1. **Enable caching** in Strapi admin panel
2. **Use a CDN** for media files
3. **Optimize database** queries
4. **Set up monitoring** with PM2 Plus or other monitoring tools

## Security Checklist

- ✅ Use strong, unique secret keys
- ✅ Enable SSL/HTTPS
- ✅ Configure firewall rules
- ✅ Regular backups of database and uploads
- ✅ Keep Strapi and dependencies updated
- ✅ Disable admin panel in production or restrict access by IP
- ✅ Use environment variables for sensitive data

## Support

- Hostinger Support: https://www.hostinger.com/support
- Strapi Documentation: https://docs.strapi.io
- Strapi Deployment Guide: https://docs.strapi.io/dev-docs/deployment

## Additional Resources

- [Strapi Production Checklist](https://docs.strapi.io/dev-docs/deployment#application-configuration)
- [PM2 Documentation](https://pm2.keymetrics.io/docs/usage/quick-start/)
- [Hostinger Node.js Hosting Guide](https://www.hostinger.com/tutorials/how-to-deploy-nodejs-app)
