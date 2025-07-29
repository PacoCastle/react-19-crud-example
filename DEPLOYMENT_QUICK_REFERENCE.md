# 🚀 Quick Deployment Reference Card

## One-Command Deployments

### 🏃‍♂️ Cloud Run (Recommended)
```powershell
.\deploy-docker.ps1 -Target cloud-run
```
**Result:** https://react-app-[hash]-uc.a.run.app

### 🏗️ App Engine
```powershell
gcloud app deploy
```
**Result:** https://my-first-react-app-467321.appspot.com

### 🖥️ Local Testing
```powershell
.\deploy-docker.ps1 -Target local
```
**Result:** http://localhost:8080

### ☸️ Kubernetes (GKE)
```powershell
.\deploy-docker.ps1 -Target gke
```
**Result:** http://[EXTERNAL-IP]

---

## 📊 Deployment Comparison

| Method | Setup Time | Cost | Scalability | Complexity |
|--------|------------|------|-------------|------------|
| **Cloud Run** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| **App Engine** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ |
| **GKE** | ⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐ |
| **Storage+CDN** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ |

---

## 🔧 Essential Commands

### Docker Commands
```powershell
# Build image
docker build -t my-react-app .

# Run locally
docker run -p 8080:8080 my-react-app

# Push to GCR
docker push gcr.io/PROJECT_ID/react-app
```

### gcloud Commands
```powershell
# Set project
gcloud config set project PROJECT_ID

# Deploy to Cloud Run
gcloud run deploy --image gcr.io/PROJECT_ID/react-app

# View logs
gcloud logs read "resource.type=cloud_run_revision"
```

### kubectl Commands
```powershell
# Deploy to GKE
kubectl apply -f k8s/

# Get services
kubectl get services

# View logs
kubectl logs -f deployment/react-app
```

---

## 🆘 Quick Troubleshooting

### "gcloud not found"
```powershell
& 'C:\Program Files (x86)\Google\Cloud SDK\google-cloud-sdk\bin\gcloud.cmd' --version
```

### "docker not found"
- Install Docker Desktop
- Restart terminal after installation

### "Port 8080 already in use"
```powershell
# Kill process on port 8080
netstat -ano | findstr :8080
taskkill /PID [PID] /F
```

### Cloud Run deployment fails
```powershell
# Check container locally first
docker run -p 8080:8080 my-react-app
curl http://localhost:8080/health
```

---

## 📝 File Checklist

Before deploying, ensure you have:
- ✅ `Dockerfile` - Container build instructions
- ✅ `.dockerignore` - Exclude unnecessary files
- ✅ `nginx.conf` - Web server configuration
- ✅ `cloudbuild.yaml` - CI/CD pipeline
- ✅ `deploy-docker.ps1` - Deployment script

---

## 🎯 Recommended Workflow

1. **Develop locally:** `npm start`
2. **Test with Docker:** `.\deploy-docker.ps1 -Target local`
3. **Deploy to staging:** `.\deploy-docker.ps1 -Target cloud-run`
4. **Set up CI/CD:** Push to GitHub (auto-deploy via Cloud Build)
5. **Production:** Use custom domain + CDN

---

## 🔗 Useful Links

- [Cloud Run Documentation](https://cloud.google.com/run/docs)
- [Docker Best Practices](https://docs.docker.com/develop/best-practices/)
- [GKE Documentation](https://cloud.google.com/kubernetes-engine/docs)
- [App Engine Documentation](https://cloud.google.com/appengine/docs)
