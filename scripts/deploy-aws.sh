#!/bin/bash

# AWS EC2 Deployment Script
# This script helps you deploy your Express.js application to AWS EC2

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="books-crud-app"
DOCKER_IMAGE="thancode99382/express-books-crud:latest"
CONTAINER_NAME="books-app"
APP_PORT=3000
HOST_PORT=80

echo -e "${BLUE}🚀 AWS EC2 Deployment Script${NC}"
echo "=================================="

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on EC2
print_status "Checking environment..."
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed!"
    echo "Please install Docker first:"
    echo "curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh"
    exit 1
fi

# Create application directory
print_status "Setting up application directory..."
mkdir -p ~/books-app
cd ~/books-app

# Create or update environment file
if [ ! -f .env ]; then
    print_warning ".env file not found. Creating template..."
    cat > .env << EOF
NODE_ENV=production
PORT=$APP_PORT
DB_HOST=your-rds-endpoint.region.rds.amazonaws.com
DB_PORT=5432
DB_NAME=books_db
DB_USER=postgres
DB_PASSWORD=your-secure-password
EOF
    print_warning "Please update .env file with your database credentials!"
    exit 1
fi

# Pull latest Docker image
print_status "Pulling latest Docker image..."
docker pull $DOCKER_IMAGE

# Stop and remove existing container
print_status "Stopping existing application..."
docker stop $CONTAINER_NAME 2>/dev/null || true
docker rm $CONTAINER_NAME 2>/dev/null || true

# Start new container
print_status "Starting new application container..."
docker run -d \
    --name $CONTAINER_NAME \
    --restart unless-stopped \
    -p $HOST_PORT:$APP_PORT \
    --env-file .env \
    $DOCKER_IMAGE

# Wait for application to start
print_status "Waiting for application to start..."
sleep 10

# Verify deployment
if docker ps | grep -q $CONTAINER_NAME; then
    print_status "✅ Application deployed successfully!"
    
    # Test health endpoint
    if curl -f http://localhost/health 2>/dev/null; then
        print_status "✅ Health check passed!"
    else
        print_warning "⚠️ Health check failed, but container is running"
    fi
    
    # Show container info
    echo ""
    echo "Container Status:"
    docker ps | grep $CONTAINER_NAME
    
    echo ""
    echo "Application Logs (last 10 lines):"
    docker logs $CONTAINER_NAME --tail 10
    
else
    print_error "❌ Deployment failed!"
    echo "Container logs:"
    docker logs $CONTAINER_NAME --tail 20
    exit 1
fi

echo ""
print_status "🎉 Deployment completed successfully!"
echo "Your application is available at:"
echo "  - Local: http://localhost"
echo "  - External: http://$(curl -s ifconfig.me 2>/dev/null || echo 'your-ec2-ip')"
echo ""
echo "Useful commands:"
echo "  View logs: docker logs $CONTAINER_NAME -f"
echo "  Stop app:  docker stop $CONTAINER_NAME"
echo "  Start app: docker start $CONTAINER_NAME"
echo "  Update:    ./deploy.sh"
