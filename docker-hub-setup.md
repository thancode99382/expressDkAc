# Docker Hub Setup Guide

## Issue: Docker Image Not Found

The deployment is failing because the Docker image `thancode99382/express-books-crud:latest` doesn't exist on Docker Hub yet.

## Quick Fix Options

### Option 1: Build Locally (Already Implemented)
The workflow now automatically builds the image locally on EC2 if it's not found on Docker Hub.

### Option 2: Configure Docker Hub (Recommended for Production)

#### Step 1: Create Docker Hub Repository
1. Go to [Docker Hub](https://hub.docker.com)
2. Sign in or create account
3. Click "Create Repository"
4. Name: `express-books-crud`
5. Set to Public
6. Click "Create"

#### Step 2: Configure GitHub Secrets
Add these **Repository Secrets** in GitHub:

1. Go to: `https://github.com/thancode99382/expressDkAc/settings/secrets/actions`
2. Add secrets:

```
Name: DOCKER_USERNAME
Value: thancode99382

Name: DOCKER_PASSWORD  
Value: [Your Docker Hub password or access token]
```

#### Step 3: Test the Pipeline
After adding secrets, push a change to trigger the build:

```bash
echo "Docker Hub configured" >> README.md
git add README.md
git commit -m "Test Docker Hub integration"
git push origin main
```

## Current Status

✅ **SSH Connection**: Working  
✅ **EC2 Setup**: Basic setup complete  
✅ **Docker Permissions**: Fixed  
🔧 **Docker Image**: Building locally as fallback  

## Expected Output After Fix

```
🚀 Starting AWS EC2 deployment...
📡 Deploying to AWS EC2 instance: ***
🔐 Testing SSH connection...
SSH connection successful
🚀 Deploying application...
📦 Getting latest application image...
🔧 Docker image not found on registry, building locally...
✅ Docker image built locally
🚀 Starting new container...
✅ Container is running!
✅ Application is responding!
✅ AWS EC2 deployment completed successfully!
```

## Manual Test (Optional)

You can test the local build manually:

```bash
# SSH into your EC2 instance
ssh -i ~/Downloads/dat.pem ubuntu@3.89.141.92

# Build and run manually
cd ~/books-app
git clone https://github.com/thancode99382/expressDkAc.git
cd expressDkAc
sudo docker build -t thancode99382/express-books-crud:latest .
cd ~/books-app
sudo docker run -d --name books-app -p 3000:3000 --env-file .env thancode99382/express-books-crud:latest
```

## Next Steps

1. **Current deployment should work** with local build fallback
2. **Optional**: Set up Docker Hub for faster deployments
3. **Test your app** at `http://3.89.141.92:3000` once deployment succeeds

The local build fallback ensures your deployment works even without Docker Hub configuration! 🚀
