# GitHub Secrets Setup Guide

This guide explains how to configure GitHub secrets for automated AWS EC2 deployment.

## Required Secrets

### Repository Secrets (for Docker Hub)
Go to **Settings** > **Secrets and variables** > **Actions** > **Repository secrets**:

1. **DOCKER_USERNAME** - Your Docker Hub username
2. **DOCKER_PASSWORD** - Your Docker Hub password or access token

### Environment Secrets (for EC2 Deployment)
Go to **Settings** > **Environments** > Create/select **production** environment:

1. **EC2_HOST** - Your EC2 instance public IP or domain name
2. **EC2_USER** - SSH username (usually `ubuntu` for Ubuntu instances)
3. **EC2_KEY** - Your private SSH key content

## Step-by-Step Setup

### 1. Configure Repository Secrets

```bash
# Navigate to your GitHub repository
# Go to Settings > Secrets and variables > Actions
# Click "New repository secret"

# Add DOCKER_USERNAME
Name: DOCKER_USERNAME
Value: your-docker-hub-username

# Add DOCKER_PASSWORD  
Name: DOCKER_PASSWORD
Value: your-docker-hub-password-or-token
```

### 2. Get Your EC2 Information

#### EC2_HOST (Public IP or Domain)
```bash
# From AWS Console:
# EC2 > Instances > Select your instance > Public IPv4 address

# Or from your EC2 instance:
curl -s ifconfig.me
```

#### EC2_USER (SSH Username)
```bash
# For Ubuntu AMI: ubuntu
# For Amazon Linux: ec2-user
# For CentOS: centos
# For Red Hat: ec2-user
```

#### EC2_KEY (Private SSH Key)
```bash
# This is the private key file you downloaded when creating the EC2 key pair
# Example: my-key-pair.pem

# Copy the entire content including:
# -----BEGIN RSA PRIVATE KEY-----
# (your key content)
# -----END RSA PRIVATE KEY-----
```

### 3. Configure Environment Secrets

```bash
# Navigate to your GitHub repository
# Go to Settings > Environments
# Click "New environment" and name it "production"
# Click "Add secret"

# Add EC2_HOST
Name: EC2_HOST
Value: 52.15.123.456  # Your EC2 public IP

# Add EC2_USER
Name: EC2_USER
Value: ubuntu

# Add EC2_KEY
Name: EC2_KEY
Value: -----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEA...
(paste your entire private key content here)
...
-----END RSA PRIVATE KEY-----
```

## Security Best Practices

### 1. Use Environment Secrets for Sensitive Data
- Environment secrets are more secure than repository secrets
- They can have additional protection rules
- Only specific environments can access them

### 2. Rotate Keys Regularly
```bash
# Generate new SSH key pair periodically
ssh-keygen -t rsa -b 4096 -f ~/.ssh/ec2-new-key
```

### 3. Limit SSH Access
```bash
# In your EC2 Security Group, restrict SSH access:
# Type: SSH
# Protocol: TCP  
# Port: 22
# Source: GitHub Actions IP ranges or your specific IPs
```

### 4. Use IAM Roles (Advanced)
For production environments, consider using IAM roles instead of SSH keys:
```bash
# This requires more setup but is more secure
# See AWS documentation for IAM roles with GitHub Actions
```

## Testing Your Setup

### 1. Verify Secrets Are Set
After setting up secrets, push a change to trigger the workflow:
```bash
git add .
git commit -m "Test deployment setup"
git push origin main
```

### 2. Check GitHub Actions
1. Go to **Actions** tab in your repository
2. Watch the workflow execution
3. Check the "Deploy to Production" step

### 3. Expected Output
```bash
✅ All deployment secrets configured
🚀 Starting AWS EC2 deployment...
📡 Deploying to AWS EC2 instance: 52.15.123.456
🔐 Testing SSH connection...
SSH connection successful
🚀 Deploying application...
✅ AWS EC2 deployment completed successfully!
```

## Troubleshooting

### Common Issues

#### 1. SSH Connection Failed
```bash
# Check security group allows SSH from GitHub
# Verify EC2 instance is running
# Confirm SSH key is correct
```

#### 2. Permission Denied
```bash
# Ensure EC2_USER is correct for your AMI
# Verify SSH key has proper format and permissions
```

#### 3. Container Start Failed
```bash
# Check .env file exists on EC2
# Verify database connection settings
# Review Docker logs: docker logs books-app
```

### Getting Helpfgfgf
```bash
# SSH into your EC2 instance to debug:
ssh -i your-key.pem ubuntu@your-ec2-ip

# Check application logs:
cd ~/books-app
docker logs books-app -f

# Check system logs:
sudo journalctl -f
```

## Next Steps

1. **Set up monitoring** - Consider CloudWatch or other monitoring solutions
2. **Configure domain** - Point your domain to the EC2 IP
3. **Enable SSL** - Use Let's Encrypt for HTTPS
4. **Set up backups** - Regular database and application backups
5. **Scale** - Consider load balancers for multiple instances

For detailed deployment instructions, see [AWS_EC2_DEPLOYMENT.md](./AWS_EC2_DEPLOYMENT.md).
