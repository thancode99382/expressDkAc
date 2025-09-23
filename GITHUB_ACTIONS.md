# 🚀 GitHub Actions Quick Reference

## Commands to Trigger Workflows

### 1. CI/CD Pipeline
```bash
# Triggers on push to main/develop
git push origin main

# Triggers on pull request to main
git checkout -b feature/my-feature
git push origin feature/my-feature
# Then create PR on GitHub
```

### 2. Release Workflow
```bash
# Create and push a version tag
git tag v1.0.0
git push origin v1.0.0

# Or create release through GitHub UI
```

### 3. Manual Triggers
```bash
# Go to GitHub → Actions tab → Select workflow → "Run workflow"
```

## 🔧 Required Secrets Setup

### Repository Secrets (Settings → Secrets and variables → Actions)
**Used by all workflows globally**

| Secret Name | Description | Required |
|-------------|-------------|----------|
| `DOCKER_USERNAME` | Docker Hub username | ✅ Yes |
| `DOCKER_PASSWORD` | Docker Hub access token | ✅ Yes |
| `SNYK_TOKEN` | Snyk API token for security scanning | ❌ Optional |

### Environment Secrets (Settings → Environments → Production)
**Used only for production deployments with approval gates**

| Secret Name | Description | Required |
|-------------|-------------|----------|
| `EC2_HOST` | AWS EC2 instance IP or domain | ❌ Optional |
| `EC2_USER` | SSH username (usually 'ubuntu') | ❌ Optional |
| `EC2_KEY` | SSH private key content | ❌ Optional |
| `AWS_ACCESS_KEY_ID` | AWS access key for API access | ❌ Optional |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key | ❌ Optional |

### Why Use Environment Secrets for Production?
- **Security**: Only accessible when deploying to production environment
- **Approval Gates**: Can require manual approval before deployment
- **Branch Protection**: Can restrict which branches can deploy
- **Audit Trail**: Better tracking of production deployments

### Setting up Repository Secrets
1. Go to your repository on GitHub
2. **Settings** → **Secrets and variables** → **Actions**
3. Click **"New repository secret"**
4. Add:
   - `DOCKER_USERNAME`: Your Docker Hub username
   - `DOCKER_PASSWORD`: Your Docker Hub access token
   - `SNYK_TOKEN`: Your Snyk API token (optional)

### Setting up Environment Secrets
1. Go to your repository on GitHub
2. **Settings** → **Environments**
3. Click **"New environment"** → Enter "production"
4. **Environment secrets** → **Add secret**:
   - `DEPLOY_HOST`: Your production server IP
   - `DEPLOY_USER`: SSH username for production server
   - `DEPLOY_KEY`: SSH private key content
5. **Protection rules** (recommended):
   - ✅ **Required reviewers**: Add team members who must approve
   - ✅ **Restrict pushes**: Only `main` branch can deploy
   - ⏱️ **Wait timer**: Optional delay before deployment

### Setting up Snyk Token (Optional)
1. Sign up at [Snyk](https://snyk.io/)
2. Account Settings → General → API Token
3. Copy token and add as `SNYK_TOKEN` **repository secret**

## 📊 Workflow Status

### Check Workflow Status
- Go to your repository on GitHub
- Click the "Actions" tab
- View recent workflow runs and their status

### Badges for README
```markdown
[![CI/CD Pipeline](https://github.com/USERNAME/REPO/actions/workflows/ci-cd.yml/badge.svg)](https://github.com/USERNAME/REPO/actions/workflows/ci-cd.yml)
```

## 🐳 Docker Integration

### Automated Image Building
- **Push to main**: Creates `latest` tag
- **Version tags**: Creates version-specific tags (e.g., `v1.0.0`)
- **Feature branches**: Creates branch-specific tags

### Using Published Images
```bash
# Latest stable version
docker pull your_username/express-books-crud:latest

# Specific version
docker pull your_username/express-books-crud:v1.0.0

# Development build
docker pull your_username/express-books-crud:main-sha123456
```

## 🔄 Workflow Triggers

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `ci-cd.yml` | Push to main/develop, PR to main | Full CI/CD pipeline |
| `pr-check.yml` | Pull request events | Quality checks for PRs |
| `dependencies.yml` | Weekly schedule, manual | Dependency updates |
| `release.yml` | Version tags | Release management |

## 🛠 Customization

### Adding New Jobs
Edit `.github/workflows/ci-cd.yml`:
```yaml
jobs:
  your-new-job:
    name: Your Job Name
    runs-on: ubuntu-latest
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
    # Add your steps here
```

### Environment-Specific Deployments
```yaml
# Add environment protection rules
environment: production
# Requires manual approval for production deploys
```

### Custom Notifications
Add to workflow files:
```yaml
- name: Slack Notification
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

## 🚨 Troubleshooting

### Common Issues

1. **Docker login fails**
   - Check `DOCKER_USERNAME` and `DOCKER_PASSWORD` secrets
   - Ensure Docker Hub token has write permissions

2. **Tests fail**
   - Check PostgreSQL service configuration
   - Verify environment variables in workflow

3. **Build fails**
   - Check Dockerfile syntax
   - Verify all dependencies are in package.json

4. **Deployment fails**
   - Check deployment secrets configuration
   - Verify target server connectivity

### Debug Steps
1. Check workflow logs in GitHub Actions tab
2. Run commands locally to reproduce issues
3. Test Docker build locally: `docker build -t test .`
4. Validate secrets are properly set

## 📚 Learn More

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Docker Hub Integration](https://docs.docker.com/ci-cd/github-actions/)
- [Workflow Syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
