#!/usr/bin/env powershell

# Docker Build and Deploy Script for React App
# This script builds the Docker image and deploys it to Google Cloud Platform

param(
    [Parameter(Mandatory=$false)]
    [string]$ProjectId = "my-first-react-app-467321",
    
    [Parameter(Mandatory=$false)]
    [string]$Region = "us-central1",
    
    [Parameter(Mandatory=$false)]
    [string]$ServiceName = "react-app",
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("cloud-run", "gke", "local")]
    [string]$Target = "cloud-run",
    
    [Parameter(Mandatory=$false)]
    [string]$Tag = "latest"
)

# Colors for output
$Green = "`e[32m"
$Yellow = "`e[33m"
$Red = "`e[31m"
$Reset = "`e[0m"

function Write-ColorOutput {
    param($Color, $Message)
    Write-Host "$Color$Message$Reset"
}

function Test-Command {
    param($Command)
    try {
        & $Command --version > $null 2>&1
        return $true
    }
    catch {
        return $false
    }
}

# Check prerequisites
Write-ColorOutput $Yellow "Checking prerequisites..."

if (-not (Test-Command "docker")) {
    Write-ColorOutput $Red "Docker is not installed or not in PATH"
    exit 1
}

if ($Target -ne "local" -and -not (Test-Command "gcloud")) {
    Write-ColorOutput $Red "Google Cloud CLI is not installed or not in PATH"
    exit 1
}

# Set image name
$ImageName = "gcr.io/$ProjectId/$ServiceName"
$FullImageName = "$ImageName`:$Tag"

Write-ColorOutput $Green "Starting deployment process..."
Write-ColorOutput $Yellow "Project ID: $ProjectId"
Write-ColorOutput $Yellow "Target: $Target"
Write-ColorOutput $Yellow "Image: $FullImageName"

# Build React application
Write-ColorOutput $Yellow "Building React application..."
npm run build
if ($LASTEXITCODE -ne 0) {
    Write-ColorOutput $Red "React build failed!"
    exit 1
}

# Build Docker image
Write-ColorOutput $Yellow "Building Docker image..."
docker build -t $FullImageName .
if ($LASTEXITCODE -ne 0) {
    Write-ColorOutput $Red "Docker build failed!"
    exit 1
}

switch ($Target) {
    "local" {
        Write-ColorOutput $Yellow "Running container locally..."
        docker stop $ServiceName 2>$null
        docker rm $ServiceName 2>$null
        
        # Try port 8080 first, then fallback to 8081, 8082, etc.
        $ports = @(8080, 8081, 8082, 8083, 3000)
        $selectedPort = $null
        
        foreach ($port in $ports) {
            $portInUse = netstat -ano | findstr ":$port "
            if (-not $portInUse) {
                $selectedPort = $port
                break
            }
        }
        
        if ($selectedPort) {
            Write-ColorOutput $Yellow "Using port $selectedPort..."
            docker run -d -p "${selectedPort}:8080" --name $ServiceName $FullImageName
            if ($LASTEXITCODE -eq 0) {
                Write-ColorOutput $Green "Container started successfully!"
                Write-ColorOutput $Green "Application available at: http://localhost:$selectedPort"
            } else {
                Write-ColorOutput $Red "Failed to start container!"
                exit 1
            }
        } else {
            Write-ColorOutput $Red "No available ports found! Tried: $($ports -join ', ')"
            exit 1
        }
    }
    
    "cloud-run" {
        Write-ColorOutput $Yellow "Pushing image to Google Container Registry..."
        docker push $FullImageName
        if ($LASTEXITCODE -ne 0) {
            Write-ColorOutput $Red "Docker push failed!"
            exit 1
        }

        Write-ColorOutput $Yellow "Deploying to Cloud Run..."
        gcloud run deploy $ServiceName `
            --image $FullImageName `
            --platform managed `
            --region $Region `
            --allow-unauthenticated `
            --port 8080 `
            --memory 512Mi `
            --cpu 1 `
            --max-instances 10 `
            --set-env-vars NODE_ENV=production `
            --project $ProjectId

        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput $Green "Deployment to Cloud Run successful!"
            $ServiceUrl = gcloud run services describe $ServiceName --platform managed --region $Region --format="value(status.url)" --project $ProjectId
            Write-ColorOutput $Green "Application available at: $ServiceUrl"
        } else {
            Write-ColorOutput $Red "Cloud Run deployment failed!"
            exit 1
        }
    }
    
    "gke" {
        Write-ColorOutput $Yellow "Pushing image to Google Container Registry..."
        docker push $FullImageName
        if ($LASTEXITCODE -ne 0) {
            Write-ColorOutput $Red "Docker push failed!"
            exit 1
        }

        Write-ColorOutput $Yellow "Deploying to Google Kubernetes Engine..."
        
        # Update deployment image
        kubectl set image deployment/react-app react-app=$FullImageName
        if ($LASTEXITCODE -ne 0) {
            Write-ColorOutput $Red "Failed to update GKE deployment!"
            exit 1
        }

        # Wait for rollout
        kubectl rollout status deployment/react-app --timeout=300s
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput $Green "Deployment to GKE successful!"
            $ServiceIP = kubectl get service react-app-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
            if ($ServiceIP) {
                Write-ColorOutput $Green "Application available at: http://$ServiceIP"
            }
        } else {
            Write-ColorOutput $Red "GKE deployment failed!"
            exit 1
        }
    }
}

Write-ColorOutput $Green "Deployment completed successfully!"
