# GitHub Actions Workflows

This project includes several GitHub Actions workflows for continuous integration, deployment, and maintenance.

## 🚀 Workflows Overview

### 1. **CI/CD Pipeline** (`.github/workflows/ci-cd.yml`)
**Triggers**: Push to `main`/`develop`, Pull Requests to `main`

**Jobs**:
- **Test & Lint**: Runs tests with PostgreSQL service, code linting
- **Security Scan**: Dependency vulnerability scanning with Snyk
- **Build**: Docker image build and push to Docker Hub
- **Deploy**: Production deployment (template provided)
- **Notify**: Success/failure notifications

### 2. **Pull Request Check** (`.github/workflows/pr-check.yml`)
**Triggers**: Pull request opened/updated

**Jobs**:
- **PR Quality Check**: Basic tests, Docker build validation
- **Automated Comments**: PR status updates

### 3. **Dependency Updates** (`.github/workflows/dependencies.yml`)
**Triggers**: Weekly schedule (Mondays 9 AM UTC), Manual dispatch

**Jobs**:
- **Update Dependencies**: Automated dependency updates with PR creation
- **Security Audit**: Weekly security vulnerability scanning

### 4. **Release Management** (`.github/workflows/release.yml`)
**Triggers**: Git tags (`v*.*.*`)

**Jobs**:
- **Create Release**: GitHub release with changelog
- **Build Release Docker**: Tagged Docker images for releases

## 🔧 Setup Requirements

### Required Secrets
Add these secrets in your GitHub repository settings:

```bash
# Docker Hub (for image publishing)
DOCKER_USERNAME=your_dockerhub_username
DOCKER_PASSWORD=your_dockerhub_token

# Optional: Snyk (for security scanning)
SNYK_TOKEN=your_snyk_token

# Optional: Deployment (customize as needed)
DEPLOY_HOST=your_server_ip
DEPLOY_USER=your_server_user
DEPLOY_KEY=your_ssh_private_key
```

### Setting up Docker Hub
1. Create account at [Docker Hub](https://hub.docker.com/)
2. Create access token in Account Settings → Security
3. Add `DOCKER_USERNAME` and `DOCKER_PASSWORD` to GitHub secrets

### Setting up Snyk (Optional)
1. Create account at [Snyk](https://snyk.io/)
2. Get API token from Account Settings
3. Add `SNYK_TOKEN` to GitHub secrets

## 📋 Workflow Features

### ✅ Automated Testing
- PostgreSQL service container for database tests
- Node.js application health checks
- Docker build validation

### 🔒 Security Features
- Dependency vulnerability scanning
- Security audit reports
- Automated security issue creation

### 🐳 Docker Integration
- Multi-platform builds (AMD64, ARM64)
- Layer caching for faster builds
- Automated image tagging

### 📦 Release Management
- Semantic version tagging
- Automated changelog generation
- Docker image versioning

## 🚀 Usage Examples

### Creating a Release
```bash
# Create and push a tag
git tag v1.0.0
git push origin v1.0.0

# This triggers the release workflow automatically
```

### Manual Dependency Update
```bash
# Go to Actions tab in GitHub
# Select "Dependency Updates" workflow
# Click "Run workflow"
```

### Deployment Customization
Edit the `deploy` job in `.github/workflows/ci-cd.yml`:

```yaml
# Example: Deploy to AWS ECS
- name: Deploy to AWS ECS
  env:
    AWS_REGION: us-east-1
  run: |
    aws ecs update-service \
      --cluster your-cluster \
      --service your-service \
      --force-new-deployment

# Example: Deploy via SSH
- name: Deploy via SSH
  run: |
    ssh user@server << 'EOF'
      cd /path/to/app
      docker-compose pull
      docker-compose up -d
    EOF
```

## 🔍 Monitoring

### Workflow Status
- Check the Actions tab in your GitHub repository
- View workflow runs, logs, and artifacts
- Monitor build times and success rates

### Docker Images
Your images will be available at:
```bash
# Latest stable
docker pull your_username/express-books-crud:latest

# Specific version
docker pull your_username/express-books-crud:v1.0.0

# Development builds
docker pull your_username/express-books-crud:main-sha123456
```

## 🛠 Troubleshooting

### Common Issues

**Build Failures**:
- Check Node.js version compatibility
- Verify all dependencies are properly declared
- Ensure Docker build context is correct

**Test Failures**:
- Database connection issues with PostgreSQL service
- Port conflicts in test environment
- Missing environment variables

**Deployment Issues**:
- Verify deployment secrets are configured
- Check target server connectivity
- Validate Docker image availability

### Debug Commands
```bash
# Local testing
npm test
docker build -t test-build .
docker-compose up -d

# Check workflow logs
# Go to Actions tab → Select workflow run → View logs
```

## 📚 Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Docker Hub Documentation](https://docs.docker.com/docker-hub/)
- [Express.js Best Practices](https://expressjs.com/en/advanced/best-practice-security.html)
- [PostgreSQL Docker Guide](https://hub.docker.com/_/postgres)

---

**Note**: These workflows are templates. Customize them according to your deployment strategy and infrastructure requirements.
