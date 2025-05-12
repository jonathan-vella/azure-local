# SQL Managed Instance Calculator for Azure Local
# This PowerShell script helps calculate resource requirements for Azure Arc-enabled SQL Managed Instance
# on Azure Local environments

# Display welcome message
Write-Host -ForegroundColor Cyan @"
###############################################################
# Azure Local SQL Managed Instance Resource Calculator
# For Azure Arc-enabled SQL MI on Azure Local
###############################################################
"@

function Show-Menu {
    param (
        [string]$Title = 'Calculator Options'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    Write-Host "1: Calculate Basic SQL MI Requirements"
    Write-Host "2: Calculate Advanced Configuration (with HA)"
    Write-Host "3: Generate Full Deployment Spec"
    Write-Host "Q: Quit"
    Write-Host "============================================="
}

function Get-WorkloadType {
    Write-Host "`nSelect Workload Type:"
    Write-Host "1: OLTP (Online Transaction Processing)"
    Write-Host "2: OLAP (Online Analytical Processing)"
    Write-Host "3: Mixed Workload"
    $workloadChoice = Read-Host "Enter choice (1-3)"
    
    switch ($workloadChoice) {
        1 { return "OLTP" }
        2 { return "OLAP" }
        3 { return "Mixed" }
        default { Write-Host "Invalid choice, defaulting to Mixed"; return "Mixed" }
    }
}

function Get-ServiceTier {
    Write-Host "`nSelect Service Tier:"
    Write-Host "1: General Purpose (Remote storage, good for most workloads)"
    Write-Host "2: Business Critical (Local storage, high performance, built-in HA)"
    $tierChoice = Read-Host "Enter choice (1-2)"
    
    switch ($tierChoice) {
        1 { return "GeneralPurpose" }
        2 { return "BusinessCritical" }
        default { Write-Host "Invalid choice, defaulting to General Purpose"; return "GeneralPurpose" }
    }
}

function Calculate-BasicRequirements {
    Write-Host "`n==== SQL MI Basic Requirements Calculator ====" -ForegroundColor Green
    
    # Get workload type
    $workloadType = Get-WorkloadType
    
    # Get service tier
    $serviceTier = Get-ServiceTier
    
    # Get database size
    [double]$dbSize = Read-Host "`nEnter database size in GB"
    
    # Get number of concurrent users
    [int]$concurrentUsers = Read-Host "Enter peak number of concurrent users"
    
    # Get transactions per second
    [int]$tps = Read-Host "Enter peak transactions per second"
    
    # Get read/write ratio
    Write-Host "`nSelect read/write ratio:"
    Write-Host "1: Read-heavy (80% read, 20% write)"
    Write-Host "2: Balanced (50% read, 50% write)"
    Write-Host "3: Write-heavy (20% read, 80% write)"
    $rwRatioChoice = Read-Host "Enter choice (1-3)"
    $rwRatio = switch ($rwRatioChoice) {
        1 { "ReadHeavy" }
        2 { "Balanced" }
        3 { "WriteHeavy" }
        default { "Balanced" }
    }
    
    # Calculate CPU requirements
    $cpuCores = switch ($workloadType) {
        "OLTP" { [math]::Max(2, [math]::Ceiling($concurrentUsers / 100)) }
        "OLAP" { [math]::Max(4, [math]::Ceiling($concurrentUsers / 50)) }
        "Mixed" { [math]::Max(4, [math]::Ceiling($concurrentUsers / 75)) }
    }
    
    # Adjust CPU for service tier
    if ($serviceTier -eq "BusinessCritical") {
        $cpuCores = [math]::Max(4, $cpuCores)
    }
    
    # Calculate memory requirements
    $bufferPool = $dbSize * 0.7
    $sqlOverhead = if ($serviceTier -eq "BusinessCritical") { 6 } else { 4 }
    $memoryGB = [math]::Ceiling($bufferPool + $sqlOverhead)
    
    # Ensure minimum memory requirements
    $memoryGB = [math]::Max(8, $memoryGB)
    
    # Calculate storage requirements
    $dataStorageGB = [math]::Ceiling($dbSize * 1.2) # 20% buffer
    $logStorageGB = switch ($rwRatio) {
        "ReadHeavy" { [math]::Ceiling($dbSize * 0.2) }
        "Balanced" { [math]::Ceiling($dbSize * 0.3) }
        "WriteHeavy" { [math]::Ceiling($dbSize * 0.4) }
    }
    
    # Calculate IOPS requirements
    $dataIOPS = $concurrentUsers * 10
    $logIOPS = $tps * 5
    
    # Calculate data controller requirements
    $dcCores = 4
    $dcMemory = 16
    
    # Display results
    Write-Host "`n==== Calculation Results ====" -ForegroundColor Green
    Write-Host "Workload Type: $workloadType"
    Write-Host "Service Tier: $serviceTier"
    
    Write-Host "`nSQL Managed Instance Requirements:"
    Write-Host "CPU cores: $cpuCores vCPU"
    Write-Host "Memory: $memoryGB GB"
    Write-Host "Data storage: $dataStorageGB GB"
    Write-Host "Log storage: $logStorageGB GB"
    Write-Host "Data IOPS: $dataIOPS IOPS"
    Write-Host "Log IOPS: $logIOPS IOPS"
    
    Write-Host "`nData Controller Requirements:"
    Write-Host "CPU cores: $dcCores vCPU"
    Write-Host "Memory: $dcMemory GB"
    
    Write-Host "`nTotal Requirements for Azure Local host:"
    $totalCores = $cpuCores + $dcCores + 2 # Adding 2 cores for system overhead
    $totalMemory = $memoryGB + $dcMemory + 8 # Adding 8 GB for system overhead
    $totalStorage = $dataStorageGB + $logStorageGB + 100 # Adding 100 GB for system
    
    Write-Host "Total CPU: $totalCores vCPU"
    Write-Host "Total Memory: $totalMemory GB"
    Write-Host "Total Storage: $totalStorage GB"
    
    # Apply host overhead
    $hostCPU = [math]::Ceiling($totalCores * 1.2) # 20% overhead
    $hostMemory = [math]::Ceiling($totalMemory * 1.2) # 20% overhead
    
    Write-Host "`nRecommended Azure Local host size (with overhead):"
    Write-Host "Host CPU: $hostCPU vCPU"
    Write-Host "Host Memory: $hostMemory GB"
    Write-Host "Host Storage: $totalStorage GB"
}

function Calculate-AdvancedConfiguration {
    Write-Host "`n==== SQL MI Advanced Configuration Calculator ====" -ForegroundColor Green
    
    # Get workload type
    $workloadType = Get-WorkloadType
    
    # Get service tier
    $serviceTier = Get-ServiceTier
    
    # Get database size
    [double]$dbSize = Read-Host "`nEnter database size in GB"
    
    # Get number of concurrent users
    [int]$concurrentUsers = Read-Host "Enter peak number of concurrent users"
    
    # Get transactions per second
    [int]$tps = Read-Host "Enter peak transactions per second"
    
    # Get high availability configuration
    Write-Host "`nHigh Availability Configuration:"
    Write-Host "1: Single instance (no HA)"
    Write-Host "2: Business Critical with HA (3 replicas)"
    $haChoice = Read-Host "Enter choice (1-2)"
    
    $haFactor = 1
    if ($haChoice -eq "2") {
        if ($serviceTier -ne "BusinessCritical") {
            Write-Host "Warning: Changing service tier to Business Critical for HA configuration" -ForegroundColor Yellow
            $serviceTier = "BusinessCritical"
        }
        $haFactor = 3
    }
    
    # Annual growth rate
    [double]$growthRate = Read-Host "`nEnter annual growth rate percentage (e.g., 20 for 20%)"
    $growthRate = $growthRate / 100
    
    # Planning horizon
    [int]$planningYears = Read-Host "Enter planning horizon in years (1-5)"
    $planningYears = [math]::Max(1, [math]::Min(5, $planningYears))
    
    # Calculate future DB size
    $futureDBSize = $dbSize * [math]::Pow((1 + $growthRate), $planningYears)
    
    # Calculate CPU requirements
    $baseCpuCores = switch ($workloadType) {
        "OLTP" { [math]::Max(2, [math]::Ceiling($concurrentUsers / 100)) }
        "OLAP" { [math]::Max(4, [math]::Ceiling($concurrentUsers / 50)) }
        "Mixed" { [math]::Max(4, [math]::Ceiling($concurrentUsers / 75)) }
    }
    
    # Adjust CPU for service tier
    if ($serviceTier -eq "BusinessCritical") {
        $baseCpuCores = [math]::Max(4, $baseCpuCores)
    }
    
    # Calculate memory requirements
    $bufferPool = $futureDBSize * 0.7
    $sqlOverhead = if ($serviceTier -eq "BusinessCritical") { 6 } else { 4 }
    $baseMemoryGB = [math]::Ceiling($bufferPool + $sqlOverhead)
    
    # Ensure minimum memory requirements
    $baseMemoryGB = [math]::Max(8, $baseMemoryGB)
    
    # Calculate storage requirements with future growth
    $dataStorageGB = [math]::Ceiling($futureDBSize * 1.2) # 20% buffer
    $logStorageGB = [math]::Ceiling($futureDBSize * 0.3)
    
    # Apply HA factor to resource calculations
    $totalCpuCores = $baseCpuCores * $haFactor
    $totalMemoryGB = $baseMemoryGB * $haFactor
    $totalDataStorageGB = $dataStorageGB * $haFactor
    $totalLogStorageGB = $logStorageGB * $haFactor
    
    # Calculate IOPS requirements
    $dataIOPS = $concurrentUsers * 10
    $logIOPS = $tps * 5
    
    # Calculate data controller requirements
    $dcCores = 4
    $dcMemory = 16
    
    # Display results
    Write-Host "`n==== Advanced Configuration Results ====" -ForegroundColor Green
    Write-Host "Workload Type: $workloadType"
    Write-Host "Service Tier: $serviceTier"
    Write-Host "High Availability: $(if ($haFactor -eq 3) {'Enabled (3 replicas)'} else {'Disabled (single instance)'})"
    Write-Host "Current Database Size: $dbSize GB"
    Write-Host "Projected Database Size (after $planningYears years): $([math]::Round($futureDBSize, 2)) GB"
    
    Write-Host "`nSQL Managed Instance Requirements (per instance):"
    Write-Host "CPU cores: $baseCpuCores vCPU"
    Write-Host "Memory: $baseMemoryGB GB"
    Write-Host "Data storage: $dataStorageGB GB"
    Write-Host "Log storage: $logStorageGB GB"
    
    Write-Host "`nTotal SQL MI Resource Requirements (with HA):"
    Write-Host "Total CPU cores: $totalCpuCores vCPU"
    Write-Host "Total Memory: $totalMemoryGB GB"
    Write-Host "Total Data storage: $totalDataStorageGB GB"
    Write-Host "Total Log storage: $totalLogStorageGB GB"
    
    Write-Host "`nData Controller Requirements:"
    Write-Host "CPU cores: $dcCores vCPU"
    Write-Host "Memory: $dcMemory GB"
    
    Write-Host "`nTotal Cluster Requirements:"
    $finalCores = $totalCpuCores + $dcCores + 2 # Adding 2 cores for system overhead
    $finalMemory = $totalMemoryGB + $dcMemory + 8 # Adding 8 GB for system overhead
    $finalStorage = $totalDataStorageGB + $totalLogStorageGB + 100 # Adding 100 GB for system
    
    Write-Host "Total CPU: $finalCores vCPU"
    Write-Host "Total Memory: $finalMemory GB"
    Write-Host "Total Storage: $finalStorage GB"
    
    # Apply host overhead
    $hostCPU = [math]::Ceiling($finalCores * 1.2) # 20% overhead
    $hostMemory = [math]::Ceiling($finalMemory * 1.2) # 20% overhead
    
    Write-Host "`nRecommended Azure Local Configuration (with overhead):"
    Write-Host "Host CPU: $hostCPU vCPU"
    Write-Host "Host Memory: $hostMemory GB"
    Write-Host "Host Storage: $finalStorage GB"
    
    Write-Host "`nRecommended Storage Performance:"
    Write-Host "Data IOPS: $dataIOPS IOPS"
    Write-Host "Log IOPS: $logIOPS IOPS"
    Write-Host "Network: 10 Gbps minimum recommended"
}

function Generate-DeploymentSpec {
    Write-Host "`n==== SQL MI Deployment Specification Generator ====" -ForegroundColor Green
    
    # Calculate advanced configuration first
    Calculate-AdvancedConfiguration
    
    # Additional deployment information
    Write-Host "`n==== Deployment Recommendations ====" -ForegroundColor Green
    
    Write-Host "`nKubernetes Requirements:"
    Write-Host "- Kubernetes version: 1.23 or later recommended"
    Write-Host "- Single control plane node with 2 vCPU and 8GB RAM minimum"
    Write-Host "- Worker nodes sized according to SQL MI and data controller requirements"
    Write-Host "- Each node should have 4 vCPU and 16GB RAM minimum"
    Write-Host "- Properly configured storage classes for data, logs, and backups"
    
    Write-Host "`nStorage Class Recommendations:"
    Write-Host "- Data: High-performance storage with proper throughput and IOPS"
    Write-Host "- Logs: Storage with low latency for transaction log performance"
    Write-Host "- Backups: ReadWriteMany (RWX) capable storage class"
    
    Write-Host "`nNetwork Requirements:"
    Write-Host "- 10 Gbps internal network minimum recommended"
    Write-Host "- Proper network security for SQL endpoints"
    Write-Host "- DNS resolution for service discovery"
    Write-Host "- Firewall rules for connectivity between components"
    
    Write-Host "`nAzure Arc Integration:"
    Write-Host "- Azure Arc-enabled Kubernetes (or K8s on Azure Stack HCI)"
    Write-Host "- Azure Arc data controller"
    Write-Host "- Azure Arc-enabled SQL Managed Instance"
    Write-Host "- Monitor through Azure Portal"
    
    Write-Host "`nFor detailed deployment guidance, refer to Microsoft documentation."
}

# Main program loop
do {
    Show-Menu
    $input = Read-Host "Please make a selection"
    switch ($input) {
        '1' { Calculate-BasicRequirements }
        '2' { Calculate-AdvancedConfiguration }
        '3' { Generate-DeploymentSpec }
        'q' { return }
    }
    pause
}
until ($input -eq 'q')
