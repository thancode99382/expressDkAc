#!/bin/bash

# AWS EC2 Initial Setup Script
# Run this script on a fresh EC2 instance to prepare it for deployment

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}[SETUP]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

echo -e "${BLUE}🔧 AWS EC2 Initial Setup${NC}"
echo "========================="

# Update system
print_status "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install Docker
print_status "Installing Docker..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker ubuntu
    rm get-docker.sh
    print_status "✅ Docker installed successfully"
else
    print_info "Docker already installed"
fi

# Install Docker Compose
print_status "Installing Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    print_status "✅ Docker Compose installed successfully"
else
    print_info "Docker Compose already installed"
fi

# Install useful tools
print_status "Installing additional tools..."
sudo apt install -y \
    curl \
    wget \
    git \
    htop \
    nginx \
    certbot \
    python3-certbot-nginx \
    postgresql-client \
    awscli

# Configure firewall (UFW)
print_status "Configuring firewall..."
sudo ufw --force enable
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https
sudo ufw allow 3000  # For testing
print_status "✅ Firewall configured"

# Create application directory
print_status "Creating application directory..."
mkdir -p ~/books-app
cd ~/books-app

# Create environment template
print_status "Creating environment template..."
cat > .env.template << EOF
# AWS EC2 Environment Configuration
NODE_ENV=production
PORT=3000

# Database Configuration (Replace with your RDS details)
DB_HOST=your-rds-endpoint.region.rds.amazonaws.com
DB_PORT=5432
DB_NAME=books_db
DB_USER=postgres
DB_PASSWORD=your-secure-password

# Optional: Add other environment variables as needed
# REDIS_URL=redis://your-redis-endpoint:6379
# JWT_SECRET=your-jwt-secret
EOF

# Create deployment script
print_status "Setting up deployment script..."
if [ ! -f deploy.sh ]; then
    wget -O deploy.sh https://raw.githubusercontent.com/thancode99382/expressDkAc/main/scripts/deploy-aws.sh 2>/dev/null || {
        echo "Warning: Could not download deploy script. Creating a basic one..."
        cat > deploy.sh << 'DEPLOY_EOF'
#!/bin/bash
echo "🚀 Deploying application..."
git pull origin main 2>/dev/null || echo "No git repository found"
docker-compose down 2>/dev/null || true
docker-compose up -d --build
echo "✅ Deployment completed!"
DEPLOY_EOF
    }
    chmod +x deploy.sh
else
    print_info "Deploy script already exists"
fi

# Create basic Nginx configuration
print_status "Creating Nginx configuration..."
sudo tee /etc/nginx/sites-available/books-app << EOF
server {
    listen 80;
    server_name _;  # Replace with your domain

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

    # Health check endpoint
    location /health {
        proxy_pass http://localhost:3000/health;
        access_log off;
    }
}
EOF

# Enable Nginx site
sudo ln -sf /etc/nginx/sites-available/books-app /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl restart nginx
sudo systemctl enable nginx

print_status "✅ EC2 instance setup completed!"

echo ""
echo -e "${YELLOW}📝 Next Steps:${NC}"
echo "1. Configure your database connection in ~/books-app/.env"
echo "2. Run deployment: cd ~/books-app && ./deploy.sh"
echo "3. Configure domain and SSL certificate (optional)"
echo ""
echo -e "${YELLOW}💡 Useful Information:${NC}"
echo "- Application directory: ~/books-app"
echo "- Nginx config: /etc/nginx/sites-available/books-app"
echo "- View logs: docker logs books-app -f"
echo "- Your external IP: $(curl -s ifconfig.me 2>/dev/null || echo 'Check AWS console')"
echo ""
echo -e "${YELLOW}🔐 Security Note:${NC}"
echo "- Update .env with your actual database credentials"
echo "- Consider setting up SSL with Let's Encrypt"
echo "- Review security groups in AWS console"

# Check if reboot is needed
if [ -f /var/run/reboot-required ]; then
    echo ""
    echo -e "${YELLOW}⚠️ System reboot required to complete Docker installation${NC}"
    echo "Run: sudo reboot"
fi
