#!/usr/bin/env powershell

# Port Conflict Resolution Script
# This script helps resolve port conflicts when deploying Docker containers

param(
    [Parameter(Mandatory=$false)]
    [int]$Port = 8080,
    
    [Parameter(Mandatory=$false)]
    [switch]$KillProcess,
    
    [Parameter(Mandatory=$false)]
    [switch]$FindAlternative
)

# Colors for output
$Green = "`e[32m"
$Yellow = "`e[33m"
$Red = "`e[31m"
$Blue = "`e[34m"
$Reset = "`e[0m"

function Write-ColorOutput {
    param($Color, $Message)
    Write-Host "$Color$Message$Reset"
}

function Test-PortAvailable {
    param([int]$TestPort)
    
    $portInUse = netstat -ano | findstr ":$TestPort "
    return -not $portInUse
}

function Get-ProcessUsingPort {
    param([int]$TestPort)
    
    $netstatOutput = netstat -ano | findstr ":$TestPort "
    if ($netstatOutput) {
        $lines = $netstatOutput -split "`n" | Where-Object { $_.Trim() -ne "" }
        foreach ($line in $lines) {
            $parts = $line -split '\s+' | Where-Object { $_ -ne "" }
            if ($parts.Length -ge 5) {
                $procId = $parts[4]
                try {
                    $process = Get-Process -Id $procId -ErrorAction SilentlyContinue
                    if ($process) {
                        return @{
                            PID = $procId
                            ProcessName = $process.ProcessName
                            Description = $process.Description
                        }
                    }
                } catch {
                    # Process might have ended
                }
            }
        }
    }
    return $null
}

function Find-AvailablePort {
    param([int]$StartPort = 8080)
    
    $testPorts = @($StartPort, 8081, 8082, 8083, 3000, 3001, 3002, 5000, 5001, 9000)
    
    foreach ($testPort in $testPorts) {
        if (Test-PortAvailable -TestPort $testPort) {
            return $testPort
        }
    }
    return $null
}

# Main script logic
Write-ColorOutput $Blue "=== Port Conflict Resolution Tool ==="
Write-ColorOutput $Yellow "Checking port $Port..."

if (Test-PortAvailable -TestPort $Port) {
    Write-ColorOutput $Green "✅ Port $Port is available!"
    exit 0
} else {
    Write-ColorOutput $Red "❌ Port $Port is in use!"
    
    $processInfo = Get-ProcessUsingPort -TestPort $Port
    if ($processInfo) {
        Write-ColorOutput $Yellow "Process Details:"
        Write-ColorOutput $Yellow "  PID: $($processInfo.PID)"
        Write-ColorOutput $Yellow "  Name: $($processInfo.ProcessName)"
        Write-ColorOutput $Yellow "  Description: $($processInfo.Description)"
    }
    
    if ($KillProcess) {
        if ($processInfo) {
            Write-ColorOutput $Yellow "Attempting to kill process $($processInfo.PID)..."
            try {
                Stop-Process -Id $processInfo.PID -Force
                Start-Sleep -Seconds 2
                
                if (Test-PortAvailable -TestPort $Port) {
                    Write-ColorOutput $Green "✅ Port $Port is now available!"
                    exit 0
                } else {
                    Write-ColorOutput $Red "❌ Port $Port is still in use!"
                }
            } catch {
                Write-ColorOutput $Red "❌ Failed to kill process: $($_.Exception.Message)"
            }
        }
    }
    
    if ($FindAlternative) {
        Write-ColorOutput $Yellow "Looking for alternative ports..."
        $availablePort = Find-AvailablePort -StartPort $Port
        
        if ($availablePort) {
            Write-ColorOutput $Green "✅ Alternative port found: $availablePort"
            Write-ColorOutput $Blue "You can use this port instead:"
            Write-ColorOutput $Blue "  docker run -p ${availablePort}:8080 your-image"
            Write-ColorOutput $Blue "  .\deploy-docker.ps1 -Target local"
            exit 0
        } else {
            Write-ColorOutput $Red "❌ No alternative ports found!"
        }
    }
    
    Write-ColorOutput $Blue ""
    Write-ColorOutput $Blue "Options to resolve this:"
    Write-ColorOutput $Blue "1. Kill the process: .\resolve-port-conflict.ps1 -Port $Port -KillProcess"
    Write-ColorOutput $Blue "2. Find alternative port: .\resolve-port-conflict.ps1 -Port $Port -FindAlternative"
    Write-ColorOutput $Blue "3. Use different port manually: docker run -p 8081:8080 your-image"
    Write-ColorOutput $Blue "4. Stop other services that might be using the port"
    
    exit 1
}
