# Docker Deployment Guide for React Application

## 🐳 Docker Overview

This guide covers how to containerize your React application using Docker and deploy it to various platforms including Google Cloud Platform.

## 📋 Prerequisites

### 1. Install Docker
- **Windows**: Download Docker Desktop from https://www.docker.com/products/docker-desktop
- **macOS**: Download Docker Desktop from https://www.docker.com/products/docker-desktop
- **Linux**: Follow instructions at https://docs.docker.com/engine/install/

### 2. Verify Docker Installation
```powershell
docker --version
docker-compose --version
```

---

## 🏗️ Project Structure for Docker

```
my-first-react-app/
├── Dockerfile              # Multi-stage Docker build
├── .dockerignore           # Files to exclude from Docker context
├── nginx.conf              # Nginx configuration for production
├── docker-compose.yml      # Local development with Docker
├── cloudbuild.yaml         # Google Cloud Build configuration
└── k8s/                    # Kubernetes manifests (optional)
    ├── deployment.yaml
    └── service.yaml
```

---

## 🐳 Docker Files Explained

### Dockerfile (Multi-stage Build)
```dockerfile
# Stage 1: Build the React application
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build

# Stage 2: Production server with Nginx
FROM nginx:alpine AS production
COPY --from=builder /app/build /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]
```

**Benefits of Multi-stage Build:**
- ✅ Smaller final image size (only production files)
- ✅ No development dependencies in production
- ✅ Better security (minimal attack surface)
- ✅ Faster deployment and scaling

### nginx.conf Configuration
```nginx
server {
    listen 8080;                    # Cloud Run requires port 8080
    root /usr/share/nginx/html;     # Serve built React files
    
    # SPA routing support
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    # Static asset caching
    location /static/ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

---

## 🚀 Building and Running Docker Images

### 1. Build the Docker Image
```powershell
# Build the image
docker build -t my-react-app .

# Build with specific tag
docker build -t my-react-app:v1.0.0 .

# Build for different platforms (Apple Silicon, Intel, etc.)
docker buildx build --platform linux/amd64,linux/arm64 -t my-react-app .
```

### 2. Run the Container Locally
```powershell
# Run the container
docker run -p 8080:8080 my-react-app

# Run in detached mode
docker run -d -p 8080:8080 --name react-container my-react-app

# Run with environment variables
docker run -p 8080:8080 -e NODE_ENV=production my-react-app
```

### 3. Test the Application
```powershell
# Open in browser
start http://localhost:8080

# Test health endpoint
curl http://localhost:8080/health
```

### 4. Container Management
```powershell
# List running containers
docker ps

# View logs
docker logs react-container

# Stop container
docker stop react-container

# Remove container
docker rm react-container

# Remove image
docker rmi my-react-app
```

---

## 🏃‍♂️ Local Development with Docker Compose

Create a `docker-compose.yml` for easier local development:

```yaml
version: '3.8'

services:
  react-app:
    build: .
    ports:
      - "8080:8080"
    environment:
      - NODE_ENV=production
    restart: unless-stopped
    
  # Optional: Add a reverse proxy
  nginx-proxy:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./proxy.conf:/etc/nginx/conf.d/default.conf
    depends_on:
      - react-app
```

### Using Docker Compose
```powershell
# Start services
docker-compose up

# Start in detached mode
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down

# Rebuild and start
docker-compose up --build
```

---

## ☁️ Google Cloud Platform Deployment

### 1. Deploy to Cloud Run (Recommended)

#### Option A: Deploy from Local Machine
```powershell
# Set your project ID
$PROJECT_ID = "my-first-react-app-467321"

# Build and push to Google Container Registry
docker build -t gcr.io/$PROJECT_ID/react-app .
docker push gcr.io/$PROJECT_ID/react-app

# Deploy to Cloud Run
gcloud run deploy react-app `
  --image gcr.io/$PROJECT_ID/react-app `
  --platform managed `
  --region us-central1 `
  --allow-unauthenticated `
  --port 8080
```

#### Option B: Deploy using Cloud Build
```powershell
# Submit build to Cloud Build
gcloud builds submit --tag gcr.io/$PROJECT_ID/react-app

# Deploy to Cloud Run
gcloud run deploy react-app `
  --image gcr.io/$PROJECT_ID/react-app `
  --platform managed `
  --region us-central1 `
  --allow-unauthenticated
```

### 2. Deploy to Google Kubernetes Engine (GKE)

#### Create Kubernetes Manifests
```yaml
# k8s/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: react-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: react-app
  template:
    metadata:
      labels:
        app: react-app
    spec:
      containers:
      - name: react-app
        image: gcr.io/PROJECT_ID/react-app:latest
        ports:
        - containerPort: 8080
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"

---
# k8s/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: react-app-service
spec:
  selector:
    app: react-app
  ports:
  - port: 80
    targetPort: 8080
  type: LoadBalancer
```

#### Deploy to GKE
```powershell
# Create GKE cluster
gcloud container clusters create react-cluster `
  --zone us-central1-a `
  --num-nodes 3

# Get credentials
gcloud container clusters get-credentials react-cluster --zone us-central1-a

# Deploy to Kubernetes
kubectl apply -f k8s/

# Get external IP
kubectl get services
```

---

## 🔄 CI/CD with Cloud Build

Create `cloudbuild.yaml` for automated builds:

```yaml
steps:
  # Build the Docker image
  - name: 'gcr.io/cloud-builders/docker'
    args: ['build', '-t', 'gcr.io/$PROJECT_ID/react-app:$COMMIT_SHA', '.']
  
  # Push to Container Registry
  - name: 'gcr.io/cloud-builders/docker'
    args: ['push', 'gcr.io/$PROJECT_ID/react-app:$COMMIT_SHA']
  
  # Deploy to Cloud Run
  - name: 'gcr.io/cloud-builders/gcloud'
    args:
    - 'run'
    - 'deploy'
    - 'react-app'
    - '--image'
    - 'gcr.io/$PROJECT_ID/react-app:$COMMIT_SHA'
    - '--region'
    - 'us-central1'
    - '--platform'
    - 'managed'
    - '--allow-unauthenticated'

images:
  - 'gcr.io/$PROJECT_ID/react-app:$COMMIT_SHA'
```

### Set up Cloud Build Trigger
```powershell
# Connect repository and create trigger
gcloud builds triggers create github `
  --repo-name="my-first-react-app" `
  --repo-owner="YOUR_GITHUB_USERNAME" `
  --branch-pattern="^main$" `
  --build-config="cloudbuild.yaml"
```

---

## 🔧 Docker Optimization Tips

### 1. Multi-stage Build Benefits
- **Smaller images**: Production image ~15MB vs ~1GB with dev dependencies
- **Faster deployments**: Less data to transfer
- **Better security**: No dev tools in production
- **Layer caching**: Faster rebuilds when dependencies don't change

### 2. Performance Optimizations
```dockerfile
# Use specific Node.js version for consistency
FROM node:20.11.0-alpine AS builder

# Install dependencies first (better caching)
COPY package*.json ./
RUN npm ci --only=production

# Copy source code after dependencies
COPY . .
```

### 3. Security Best Practices
```dockerfile
# Use non-root user
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001
USER nextjs

# Use specific versions
FROM nginx:1.25-alpine

# Remove unnecessary packages
RUN apk del .build-deps
```

---

## 📊 Monitoring and Logging

### 1. Application Monitoring
```powershell
# View Cloud Run logs
gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=react-app"

# Set up monitoring
gcloud alpha monitoring policies create --policy-from-file=monitoring-policy.yaml
```

### 2. Container Health Checks
```dockerfile
# Add health check to Dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1
```

---

## 💰 Cost Optimization

### Cloud Run Pricing Benefits:
- ✅ **Pay per request**: No cost when not in use
- ✅ **Auto-scaling**: Scales to zero when idle
- ✅ **Generous free tier**: 2 million requests/month free
- ✅ **Fast cold starts**: Nginx starts quickly

### GKE vs Cloud Run Comparison:
| Feature | Cloud Run | GKE |
|---------|-----------|-----|
| **Complexity** | Low | High |
| **Cost (low traffic)** | Lower | Higher |
| **Scaling** | Automatic | Manual/HPA |
| **Maintenance** | Minimal | More involved |
| **Best for** | Web apps, APIs | Complex workloads |

---

## 🛠️ Troubleshooting

### Common Issues:

#### 1. Port Issues
```dockerfile
# Make sure to expose port 8080 for Cloud Run
EXPOSE 8080
```

#### 2. Build Context Too Large
```bash
# Check .dockerignore file
# Exclude node_modules, .git, build folders
```

#### 3. Permission Issues
```dockerfile
# Set proper permissions
RUN chown -R 1001:1001 /usr/share/nginx/html
USER 1001
```

#### 4. Memory Issues
```yaml
# Set resource limits in Cloud Run
resources:
  limits:
    memory: 512Mi
    cpu: 1000m
```

### Debug Commands:
```powershell
# Check image layers
docker history my-react-app

# Inspect running container
docker exec -it react-container sh

# Check nginx configuration
docker exec react-container nginx -t

# View container logs
docker logs -f react-container
```

---

This Docker deployment guide provides multiple deployment options and best practices for containerizing and deploying your React application to Google Cloud Platform!
