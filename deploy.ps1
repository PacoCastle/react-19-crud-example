#!/usr/bin/env powershell

# React App Deployment Script for Google Cloud Platform
# This script builds the React app and deploys it to Google App Engine

Write-Host "Starting React App Deployment to GCP..." -ForegroundColor Green

# Build the React application
Write-Host "Building React application..." -ForegroundColor Yellow
npm run build

if ($LASTEXITCODE -eq 0) {
    Write-Host "Build successful!" -ForegroundColor Green
    
    # Deploy to Google App Engine
    Write-Host "Deploying to Google App Engine..." -ForegroundColor Yellow
    gcloud app deploy --quiet
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Deployment successful!" -ForegroundColor Green
        Write-Host "Opening your deployed app..." -ForegroundColor Yellow
        gcloud app browse
    } else {
        Write-Host "Deployment failed!" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "Build failed!" -ForegroundColor Red
    exit 1
}
