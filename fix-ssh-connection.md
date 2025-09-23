# AWS Security Group Fix for GitHub Actions

## Quick Fix (Less Secure but Works)

1. **AWS Console** → EC2 → Security Groups
2. Find your EC2 instance's security group
3. **Inbound Rules** → Edit
4. Add/Update these rules:

```
Type: SSH
Protocol: TCP  
Port: 22
Source: 0.0.0.0/0
Description: Allow SSH from anywhere
```

```
Type: HTTP
Protocol: TCP
Port: 80  
Source: 0.0.0.0/0
Description: Allow HTTP from anywhere
```

```
Type: Custom TCP
Protocol: TCP
Port: 3000
Source: 0.0.0.0/0  
Description: Allow app access
```

## More Secure Fix (GitHub Actions IPs Only)

Add these specific IP ranges for GitHub Actions:

```bash
# GitHub Actions IP ranges (as of 2025)
4.175.0.0/14
13.64.0.0/11
13.96.0.0/13
13.104.0.0/14
20.20.0.0/14
20.36.0.0/14
20.40.0.0/13
20.48.0.0/12
20.64.0.0/10
20.128.0.0/16
20.135.0.0/16
20.150.0.0/15
20.152.0.0/13
20.160.0.0/12
20.176.0.0/14
20.180.0.0/14
20.184.0.0/13
20.192.0.0/10
40.64.0.0/10
40.128.0.0/17
52.159.0.0/16
52.167.0.0/16
52.170.0.0/15
52.172.0.0/14
52.176.0.0/13
52.184.0.0/13
52.224.0.0/11
191.232.0.0/13
191.240.0.0/12
```

## Verify Your EC2 Instance

### Check if EC2 is Running
```bash
# In AWS Console: EC2 → Instances
# Status should show: Running ✅
# Public IP should match: 3.89.141.92
```

### Test SSH Manually
```bash
# From your local machine:
ssh -i ~/Downloads/dat.pem ubuntu@3.89.141.92

# If this fails with same timeout, it's definitely a security group issue
```

## Step-by-Step Fix

### 1. AWS Console Method
1. Go to **AWS Console** → **EC2**
2. Click **Security Groups** (left sidebar)
3. Find the security group attached to instance `i-0f338bedf6a46b8ce`
4. Click **Edit inbound rules**
5. Add SSH rule with source `0.0.0.0/0`

### 2. AWS CLI Method (if you have AWS CLI)
```bash
# Get your security group ID
aws ec2 describe-instances --instance-ids i-0f338bedf6a46b8ce

# Add SSH rule (replace sg-xxxxxxxx with your security group ID)
aws ec2 authorize-security-group-ingress \
  --group-id sg-xxxxxxxx \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0
```

### 3. Quick Test After Fix
```bash
# Test SSH connection manually
ssh -i ~/Downloads/dat.pem ubuntu@3.89.141.92

# Should connect successfully without timeout
```

## Expected Output After Fix

Once the security group is updated, your GitHub Actions should show:

```
🚀 Starting AWS EC2 deployment...
📡 Deploying to AWS EC2 instance: ***
🔐 Testing SSH connection...
SSH connection successful
🚀 Deploying application...
```

## Common Security Group Issues

1. **Wrong Source IP**: Must allow GitHub Actions IPs or `0.0.0.0/0`
2. **Wrong Port**: Must be port 22 for SSH
3. **Wrong Protocol**: Must be TCP
4. **Multiple Security Groups**: Check all security groups attached to the instance

## After Fixing Security Group

1. **Re-run the workflow** by pushing a small change:
   ```bash
   echo "Test deployment after security group fix" >> README.md
   git add README.md
   git commit -m "Test deployment with fixed security group"
   git push origin main
   ```

2. **Monitor the Actions tab** to see if SSH connection succeeds

The most common cause of this timeout is the security group not allowing SSH access. Fix the security group and your deployment should work! 🚀
