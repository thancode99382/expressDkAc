#!/bin/bash

# Books CRUD Application Docker Build Script

set -e

echo "🐳 Books CRUD Application Docker Setup"
echo "======================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker Compose is installed
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose V2 is available
if docker compose version &> /dev/null; then
    DOCKER_COMPOSE="docker compose"
elif command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE="docker-compose"
else
    print_error "Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Function to build the application
build_app() {
    print_status "Building Books CRUD Application Docker image..."
    docker build -t books-crud-app .
    print_success "Docker image built successfully!"
}

# Function to start services with Docker Compose
start_services() {
    print_status "Starting services with Docker Compose..."
    $DOCKER_COMPOSE up -d
    print_success "Services started successfully!"
    print_status "Application will be available at: http://localhost:3000"
    print_status "Database will be available at: localhost:5432"
}

# Function to stop services
stop_services() {
    print_status "Stopping services..."
    $DOCKER_COMPOSE down
    print_success "Services stopped successfully!"
}

# Function to view logs
view_logs() {
    print_status "Viewing application logs..."
    $DOCKER_COMPOSE logs -f app
}

# Function to view database logs
view_db_logs() {
    print_status "Viewing database logs..."
    $DOCKER_COMPOSE logs -f db
}

# Function to clean up
cleanup() {
    print_status "Cleaning up Docker resources..."
    $DOCKER_COMPOSE down -v
    docker rmi books-crud-app 2>/dev/null || true
    print_success "Cleanup completed!"
}

# Function to show status
show_status() {
    print_status "Service Status:"
    $DOCKER_COMPOSE ps
}

# Main menu
case "${1:-}" in
    "build")
        build_app
        ;;
    "start")
        start_services
        ;;
    "stop")
        stop_services
        ;;
    "restart")
        stop_services
        start_services
        ;;
    "logs")
        view_logs
        ;;
    "db-logs")
        view_db_logs
        ;;
    "status")
        show_status
        ;;
    "cleanup")
        cleanup
        ;;
    "help" | "--help" | "-h")
        echo "Books CRUD Application Docker Management Script"
        echo ""
        echo "Usage: $0 [COMMAND]"
        echo ""
        echo "Commands:"
        echo "  build     Build the Docker image"
        echo "  start     Start all services"
        echo "  stop      Stop all services"
        echo "  restart   Restart all services"
        echo "  logs      View application logs"
        echo "  db-logs   View database logs"
        echo "  status    Show service status"
        echo "  cleanup   Clean up all Docker resources"
        echo "  help      Show this help message"
        echo ""
        echo "Examples:"
        echo "  $0 build"
        echo "  $0 start"
        echo "  $0 logs"
        ;;
    *)
        print_warning "No command specified. Use '$0 help' for usage information."
        echo ""
        echo "Quick start:"
        echo "1. $0 build"
        echo "2. $0 start"
        echo "3. Open http://localhost:3000 in your browser"
        ;;
esac
