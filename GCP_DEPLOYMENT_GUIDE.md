# Google Cloud Platform Deployment Instructions

## 🚀 Deployment Options Overview

This guide covers **multiple deployment methods** for your React application on Google Cloud Platform:

1. **🏃‍♂️ Cloud Run (Recommended)** - Containerized, serverless, auto-scaling
2. **🏗️ App Engine** - Platform-as-a-Service, simple deployment
3. **☸️ Google Kubernetes Engine (GKE)** - Full container orchestration
4. **🌐 Cloud Storage + CDN** - Static hosting with global distribution

---

## 📋 Prerequisites Setup

### 1. Install Google Cloud SDK
**IMPORTANT: You need to install this first!**

1. Download from: https://cloud.google.com/sdk/docs/install-windows
2. Run the installer (GoogleCloudSDKInstaller.exe)
3. Follow the installation wizard
4. **Restart PowerShell/VS Code terminal** after installation
5. Verify installation by running: `gcloud --version`

If `gcloud` command is not recognized:
- Close and reopen your terminal
- Or run: `& 'C:\Program Files (x86)\Google\Cloud SDK\google-cloud-sdk\bin\gcloud.cmd' --version`

### 2. Install Docker (for Container Deployments)
1. Download Docker Desktop from: https://www.docker.com/products/docker-desktop
2. Install and restart your machine
3. Verify installation: `docker --version`

### 3. Initialize Google Cloud
Run these commands in your terminal:

```powershell
# Initialize gcloud and authenticate
gcloud init

# Login to your Google Cloud account
gcloud auth login

# Set your project (you'll need to create one first)
gcloud config set project my-first-react-app-467321
```

---

## ☁️ Method 1: Cloud Run Deployment (Recommended)

**✅ Best for:** Production apps, auto-scaling, cost-effective  
**✅ Benefits:** Pay-per-request, scales to zero, HTTPS included, custom domains

### Step 1: Enable Required APIs
```powershell
gcloud services enable cloudbuild.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable containerregistry.googleapis.com
```

### Step 2: Build and Deploy
```powershell
# Option A: Automated script
.\deploy-docker.ps1 -Target cloud-run

# Option B: Manual deployment
# Build and push Docker image
docker build -t gcr.io/my-first-react-app-467321/react-app .
docker push gcr.io/my-first-react-app-467321/react-app

# Deploy to Cloud Run
gcloud run deploy react-app `
  --image gcr.io/my-first-react-app-467321/react-app `
  --platform managed `
  --region us-central1 `
  --allow-unauthenticated `
  --port 8080
```

### Step 3: Access Your App
```powershell
# Get the service URL
gcloud run services describe react-app --platform managed --region us-central1 --format="value(status.url)"
```

**🌐 Your app will be available at:** `https://react-app-[hash]-uc.a.run.app`

---

## 🏗️ Method 2: App Engine Deployment (Legacy)

**✅ Best for:** Simple deployments, beginners  
**⚠️ Note:** Less flexible than Cloud Run

### Step 1: Create a Google Cloud Project
### Step 1: Create a Google Cloud Project
1. Go to https://console.cloud.google.com/
2. Click "Create Project"
3. Enter a project name (e.g., "my-first-react-app")
4. Note the Project ID (it will be auto-generated)

### Step 2: Enable App Engine API
```powershell
gcloud services enable appengine.googleapis.com
```

### Step 3: Initialize App Engine
```powershell
gcloud app create --region=us-central1
```

### Step 4: Deploy to Google App Engine
From your React app directory, run:

```powershell
# Make sure you're in the right directory
Set-Location "c:\GitHubClean\React\my-first-react-app"

# Deploy to App Engine
gcloud app deploy

# View your deployed app
gcloud app browse
```

---

## ☸️ Method 3: Google Kubernetes Engine (GKE)

**✅ Best for:** Complex applications, microservices, advanced scaling  
**⚠️ Note:** More complex setup, higher minimum cost

### Step 1: Enable GKE API
```powershell
gcloud services enable container.googleapis.com
gcloud services enable cloudbuild.googleapis.com
```

### Step 2: Create GKE Cluster
```powershell
# Create cluster
gcloud container clusters create react-cluster `
  --zone us-central1-a `
  --num-nodes 3 `
  --enable-autoscaling `
  --min-nodes 1 `
  --max-nodes 10

# Get credentials
gcloud container clusters get-credentials react-cluster --zone us-central1-a
```

### Step 3: Build and Push Image
```powershell
# Build and push Docker image
docker build -t gcr.io/my-first-react-app-467321/react-app .
docker push gcr.io/my-first-react-app-467321/react-app
```

### Step 4: Deploy to Kubernetes
```powershell
# Update the PROJECT_ID in k8s/deployment.yaml first
# Then deploy
kubectl apply -f k8s/

# Get external IP
kubectl get services react-app-service
```

---

## 🌐 Method 4: Cloud Storage + CDN (Static Hosting)

**✅ Best for:** Static sites, lowest cost, global distribution  
**⚠️ Note:** No server-side functionality

### Step 1: Create Storage Bucket
```powershell
# Create bucket
gsutil mb gs://my-react-app-static

# Set bucket policy
gsutil iam ch allUsers:objectViewer gs://my-react-app-static
```

### Step 2: Build and Upload
```powershell
# Build React app
npm run build

# Upload to bucket
gsutil -m rsync -r -d build gs://my-react-app-static

# Set main page
gsutil web set -m index.html -e index.html gs://my-react-app-static
```

### Step 3: Set up CDN (Optional)
```powershell
# Create load balancer with CDN
gcloud compute backend-buckets create react-app-backend --gcs-bucket-name=my-react-app-static
```

---

## 🔄 CI/CD with Cloud Build

### Automated Deployment Setup

#### Step 1: Connect Repository
```powershell
# Create Cloud Build trigger
gcloud builds triggers create github `
  --repo-name="my-first-react-app" `
  --repo-owner="YOUR_GITHUB_USERNAME" `
  --branch-pattern="^main$" `
  --build-config="cloudbuild.yaml"
```

#### Step 2: Automatic Deployments
Every push to the `main` branch will:
1. ✅ Run tests
2. ✅ Build React app
3. ✅ Create Docker image
4. ✅ Deploy to Cloud Run
5. ✅ Update live application

---

## 💰 Cost Comparison

| Method | Free Tier | Cost (Low Traffic) | Cost (High Traffic) | Best For |
|--------|-----------|-------------------|-------------------|----------|
| **Cloud Run** | 2M requests/month | $0-10/month | Scales with usage | Most apps |
| **App Engine** | 28 instance hours/day | $10-30/month | $50-200/month | Simple apps |
| **GKE** | None | $75-100/month | $200-500/month | Enterprise |
| **Cloud Storage** | 5GB storage | $1-5/month | $10-50/month | Static sites |

---

## 🛠️ Quick Start Commands

### For Cloud Run (Recommended):
```powershell
# One-command deployment
.\deploy-docker.ps1 -Target cloud-run
```

### For App Engine:
```powershell
# Traditional deployment
gcloud app deploy
```

### For Local Testing:
```powershell
# Test Docker container locally
.\deploy-docker.ps1 -Target local
```

---

## Build and Deploy Script
You can also create a deployment script for future deployments:

```powershell
# For Cloud Run (Docker-based)
.\deploy-docker.ps1 -Target cloud-run

# For App Engine (Traditional)
npm run build; gcloud app deploy

# For local testing
.\deploy-docker.ps1 -Target local
```

## 🎯 Deployment Method Recommendations

### Choose Cloud Run if:
- ✅ You want modern, scalable deployment
- ✅ You need auto-scaling and pay-per-request pricing
- ✅ You want containerized applications
- ✅ You need custom domains and HTTPS

### Choose App Engine if:
- ✅ You prefer simple, traditional deployment
- ✅ You don't want to deal with Docker
- ✅ You have a simple application
- ✅ You're new to cloud deployment

### Choose GKE if:
- ✅ You have complex microservices architecture
- ✅ You need advanced Kubernetes features
- ✅ You have dedicated DevOps resources
- ✅ You need fine-grained control over infrastructure

### Choose Cloud Storage if:
- ✅ You have a purely static React app
- ✅ You want the lowest possible cost
- ✅ You need global CDN distribution
- ✅ You don't need server-side functionality

## Important Notes
- **Cloud Run**: Your app will be available at: `https://react-app-[hash]-uc.a.run.app`
- **App Engine**: Your app will be available at: `https://YOUR_PROJECT_ID.appspot.com`
- **GKE**: Your app will be available at the LoadBalancer IP address
- **Cloud Storage**: Your app will be available at: `https://storage.googleapis.com/BUCKET_NAME/index.html`

All methods automatically handle HTTPS and provide production-ready hosting.

## Troubleshooting
## Troubleshooting

### Cloud Run Issues:
**Port Configuration:**
- Ensure your Docker container exposes port 8080
- Cloud Run expects applications to listen on the PORT environment variable

**Memory/CPU Issues:**
```powershell
# Increase resources if needed
gcloud run deploy react-app --memory 1Gi --cpu 2
```

**Container Registry Authentication:**
```powershell
# Configure Docker to use gcloud as credential helper
gcloud auth configure-docker
```

### App Engine Issues:
**Runtime Error Fix:**
If you get an error about nodejs18 being end of support:
1. The app.yaml file has been updated to use python312 runtime
2. Make sure your app.yaml contains: `runtime: python312`

**Build Issues:**
```powershell
# Enable required APIs
gcloud services enable cloudbuild.googleapis.com
gcloud services enable containerregistry.googleapis.com
```

### Docker Issues:
**Build Context Too Large:**
- Check your `.dockerignore` file
- Ensure `node_modules` and `build` folders are excluded

**Permission Issues:**
```powershell
# On Windows, ensure Docker Desktop is running
# On Linux, add user to docker group
sudo usermod -aG docker $USER
```

### GKE Issues:
**Cluster Access:**
```powershell
# Get cluster credentials
gcloud container clusters get-credentials CLUSTER_NAME --zone ZONE
```

**Image Pull Issues:**
```powershell
# Ensure proper permissions
kubectl create secret docker-registry gcr-json-key `
  --docker-server=gcr.io `
  --docker-username=_json_key `
  --docker-password="$(cat key.json)" `
  --docker-email=any@example.com
```

## Cost Considerations
- Google App Engine has a free tier
- Static websites typically stay within free usage limits
- Monitor usage in the GCP Console: https://console.cloud.google.com/
