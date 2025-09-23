# Deployment Debugging Guide

## Quick Diagnostics

### 1. Check Your GitHub Secrets Configuration

Go to: `https://github.com/thancode99382/expressDkAc/settings/environments`

**Required Environment Secrets (production environment):**
- ✅ EC2_HOST: `3.89.141.92`
- ✅ EC2_USER: `ubuntu`  
- ✅ EC2_KEY: (Your private key content from dat.pem)

**Required Repository Secrets:**
Go to: `https://github.com/thancode99382/expressDkAc/settings/secrets/actions`
- ✅ DOCKER_USERNAME: Your Docker Hub username
- ✅ DOCKER_PASSWORD: Your Docker Hub password/token

### 2. Test SSH Connection Manually

```bash
# Test if you can SSH into your EC2 instance
ssh -i ~/Downloads/dat.pem ubuntu@3.89.141.92

# If this fails, check:
# 1. EC2 instance is running
# 2. Security group allows SSH (port 22)
# 3. Key file permissions: chmod 400 ~/Downloads/dat.pem
```

### 3. Check EC2 Security Group

In AWS Console:
1. Go to EC2 > Security Groups
2. Find your instance's security group
3. Verify Inbound Rules include:
   - **SSH (22)** from `0.0.0.0/0` or GitHub Actions IP ranges
   - **HTTP (80)** from `0.0.0.0/0`
   - **HTTPS (443)** from `0.0.0.0/0`

### 4. Verify EC2 Instance Status

```bash
# Check if your EC2 instance is running
# In AWS Console: EC2 > Instances
# Status should be: Running ✅
```

### 5. Common Error Solutions

#### A. "Secrets not configured"
- Go to GitHub > Settings > Environments > production
- Add all three environment secrets

#### B. "SSH connection failed"
- Verify EC2 is running and accessible
- Check security group allows SSH
- Verify EC2_KEY contains the correct private key

#### C. "Docker pull failed"  
- Verify DOCKER_USERNAME and DOCKER_PASSWORD are correct
- Check Docker Hub repository exists

#### D. "Container failed to start"
- SSH into EC2 and run setup script first
- Verify .env file exists in ~/books-app/

### 6. Step-by-Step Verification

1. **Check GitHub Actions Status**:
   - Go to Actions tab in your repository
   - Look for red ❌ or yellow ⚠️ indicators

2. **Manual SSH Test**:
   ```bash
   ssh -i ~/Downloads/dat.pem ubuntu@3.89.141.92
   ```

3. **Setup EC2 if needed**:
   ```bash
   # On your EC2 instance:
   wget https://raw.githubusercontent.com/thancode99382/expressDkAc/main/scripts/setup-ec2.sh
   chmod +x setup-ec2.sh
   ./setup-ec2.sh
   ```

4. **Configure Environment**:
   ```bash
   # On your EC2 instance:
   cd ~/books-app
   cp .env.template .env
   nano .env  # Add your database configuration
   ```

### 7. Expected Workflow Success Output

```
✅ All deployment secrets configured
🚀 Starting AWS EC2 deployment...
📡 Deploying to AWS EC2 instance: 3.89.141.92
🔐 Testing SSH connection...
SSH connection successful
🚀 Deploying application...
✅ Container is running!
✅ Application health check passed!
✅ AWS EC2 deployment completed successfully!
```

## Need Help?

1. **Check the Actions tab** in your GitHub repository
2. **Copy the exact error message** from the failed workflow
3. **Run manual SSH test** to verify connectivity
4. **Verify all secrets are configured** in the correct locations

Most deployment issues are due to missing secrets or SSH connectivity problems.
