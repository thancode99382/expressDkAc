# 🚀 AWS EC2 Deployment Guide

Deploy your Express.js Books CRUD application to AWS EC2 with automated CI/CD.

## 🎯 **Architecture Overview**

```
GitHub Actions → Docker Hub → AWS EC2 → RDS PostgreSQL
```

- **EC2 Instance**: Ubuntu 22.04 with Docker
- **RDS Database**: Managed PostgreSQL
- **Security Groups**: Configured for web traffic
- **Elastic IP**: Static IP address
- **Auto-deployment**: Triggered by GitHub pushes

## 📋 **Prerequisites**

- ✅ AWS Account (free tier available)
- ✅ GitHub repository with working CI/CD (you have this!)
- ✅ Docker image published (done!)
- 🆕 AWS CLI configured locally (optional)

## 🚀 **Step-by-Step Deployment**

### **Phase 1: Create RDS PostgreSQL Database**

1. **Go to AWS Console** → **RDS**
2. **Create Database**:
   ```
   Engine: PostgreSQL
   Version: 15.x
   Template: Free tier (or Production for live apps)
   DB Instance: db.t3.micro (free tier)
   Database name: books_db
   Username: postgres
   Password: [secure password]
   ```
3. **Configure Connectivity**:
   ```
   VPC: Default VPC
   Public access: Yes (for initial setup)
   Security group: Create new (or use default)
   ```
4. **Save connection details** for later

### **Phase 2: Create EC2 Instance**

1. **Go to AWS Console** → **EC2**
2. **Launch Instance**:
   ```
   Name: books-crud-server
   AMI: Ubuntu Server 22.04 LTS
   Instance type: t2.micro (free tier) or t3.small
   Key pair: Create new or use existing
   ```
3. **Configure Security Group**:
   ```
   SSH (22): Your IP
   HTTP (80): 0.0.0.0/0
   HTTPS (443): 0.0.0.0/0
   Custom (3000): 0.0.0.0/0 (for testing)
   PostgreSQL (5432): Security group of RDS
   ```
4. **Storage**: 8-20 GB gp3
5. **Launch Instance**

### **Phase 3: Allocate Elastic IP**

1. **EC2 Console** → **Elastic IPs**
2. **Allocate Elastic IP**
3. **Associate** with your instance
4. **Save the IP address**

### **Phase 4: Configure EC2 Instance**

SSH into your instance:
```bash
ssh -i your-key.pem ubuntu@your-elastic-ip
```

Install Docker and dependencies:
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker ubuntu

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Install AWS CLI (for deployment automation)
sudo apt install awscli -y

# Reboot to apply group changes
sudo reboot
```

### **Phase 5: Deploy Application**

After reboot, SSH back in:
```bash
ssh -i your-key.pem ubuntu@your-elastic-ip

# Create application directory
mkdir -p ~/books-app
cd ~/books-app

# Create environment file
cat > .env << EOF
NODE_ENV=production
PORT=3000
DB_HOST=your-rds-endpoint.region.rds.amazonaws.com
DB_PORT=5432
DB_NAME=books_db
DB_USER=postgres
DB_PASSWORD=your-rds-password
EOF

# Pull and run your Docker image
docker pull thancode99382/express-books-crud:latest

docker run -d \
  --name books-app \
  --restart unless-stopped \
  -p 80:3000 \
  --env-file .env \
  thancode99382/express-books-crud:latest

# Check if running
docker ps
curl http://localhost/health
```

### **Phase 6: Initialize Database**

```bash
# Install PostgreSQL client
sudo apt install postgresql-client -y

# Connect to RDS and create schema
psql -h your-rds-endpoint.region.rds.amazonaws.com -U postgres -d books_db

# Copy and paste content from your database/schema.sql file
# Or upload schema file and run:
# psql -h your-rds-endpoint.region.rds.amazonaws.com -U postgres -d books_db -f schema.sql
```

## 🔧 **Automated Deployment with GitHub Actions**

Your application is now accessible at `http://your-elastic-ip`

For automated deployments, you'll need:

### **AWS Secrets for GitHub Actions**

1. **Create IAM User** with EC2 and ECR permissions
2. **Generate Access Keys**
3. **Add to GitHub Secrets**:
   ```
   AWS_ACCESS_KEY_ID=your-access-key
   AWS_SECRET_ACCESS_KEY=your-secret-key
   AWS_REGION=us-east-1
   EC2_HOST=your-elastic-ip
   EC2_USER=ubuntu
   EC2_KEY=your-private-key-content
   ```

## 🔒 **Security Hardening**

### **Configure SSL with Let's Encrypt**

```bash
# Install Nginx
sudo apt install nginx -y

# Install Certbot
sudo apt install certbot python3-certbot-nginx -y

# Configure Nginx (create /etc/nginx/sites-available/books-app)
sudo tee /etc/nginx/sites-available/books-app << EOF
server {
    listen 80;
    server_name your-domain.com;  # Replace with your domain

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

# Enable site
sudo ln -s /etc/nginx/sites-available/books-app /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

# Get SSL certificate
sudo certbot --nginx -d your-domain.com
```

### **Update Security Groups**

After SSL setup:
- Remove port 3000 from public access
- Keep only ports 22 (SSH), 80 (HTTP), 443 (HTTPS)

## 📊 **Monitoring & Maintenance**

### **View Application Logs**
```bash
docker logs books-app -f
```

### **Update Application**
```bash
# Pull latest image
docker pull thancode99382/express-books-crud:latest

# Stop and remove old container
docker stop books-app
docker rm books-app

# Start new container
docker run -d \
  --name books-app \
  --restart unless-stopped \
  -p 80:3000 \
  --env-file .env \
  thancode99382/express-books-crud:latest
```

### **Database Backups**
```bash
# Backup database
pg_dump -h your-rds-endpoint.region.rds.amazonaws.com -U postgres books_db > backup.sql

# Restore database
psql -h your-rds-endpoint.region.rds.amazonaws.com -U postgres books_db < backup.sql
```

## 💰 **Cost Optimization**

### **Free Tier Usage**
- **EC2 t2.micro**: 750 hours/month free
- **RDS db.t3.micro**: 750 hours/month free
- **EBS Storage**: 30 GB free
- **Data Transfer**: 15 GB free

### **Production Recommendations**
- **EC2**: t3.small or t3.medium
- **RDS**: db.t3.small with Multi-AZ
- **Load Balancer**: Application Load Balancer
- **Auto Scaling**: For high traffic

## 🚨 **Troubleshooting**

### **Common Issues**

1. **Connection Refused**
   - Check security groups
   - Verify application is running: `docker ps`
   - Check logs: `docker logs books-app`

2. **Database Connection**
   - Verify RDS endpoint and credentials
   - Check security group allows EC2 → RDS
   - Test connection: `telnet rds-endpoint 5432`

3. **Port 80 Permission Denied**
   - Use port 3000 for testing
   - Configure Nginx for production

## 📚 **Next Steps**

1. **Domain Setup**: Point your domain to Elastic IP
2. **SSL Certificate**: Configure HTTPS with Let's Encrypt
3. **Monitoring**: Set up CloudWatch alarms
4. **Backups**: Automate RDS snapshots
5. **Auto-scaling**: Configure for high traffic

## 🎯 **Quick Checklist**

- [ ] Create RDS PostgreSQL database
- [ ] Launch EC2 instance with security groups
- [ ] Allocate and associate Elastic IP
- [ ] Install Docker on EC2
- [ ] Deploy application container
- [ ] Initialize database schema
- [ ] Configure domain and SSL (optional)
- [ ] Set up monitoring and backups

Your application will be live at: `http://your-elastic-ip` or `https://your-domain.com`

🎉 **Happy deploying!**
