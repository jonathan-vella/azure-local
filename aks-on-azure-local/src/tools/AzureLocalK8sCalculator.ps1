# AzureLocalK8sCalculator.ps1
# PowerShell calculator for sizing Kubernetes on Azure Local
# This script helps determine the right size for Kubernetes clusters running on Azure Local
# by calculating resource requirements based on workload specifications and applying best practices.

# Clear the screen and display welcome message
Clear-Host
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host "  Azure Local Kubernetes Sizing Calculator" -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host "This tool will help you right-size your Kubernetes deployment on Azure Local."
Write-Host "Please provide the requested information about your workloads and requirements."
Write-Host ""

# Initialize variables with default values
$overheadFactor = 0.25 # 25% overhead for Kubernetes system components
$haFactor = 0 # Will be calculated based on min nodes
$hostOsOverhead = 0.1 # 10% for host OS
$vmOverhead = 0.05 # 5% for VM hypervisor
$arcOverhead = 0.1 # 10% for Azure Arc components
$targetUtilization = 0.7 # Target 70% utilization to allow for spikes

# Function to get validated numeric input
function Get-ValidatedInput {
    param (
        [string]$prompt,
        [double]$min = 0,
        [double]$max = [double]::MaxValue,
        [double]$default = 0
    )
    
    do {
        $input = Read-Host "$prompt [Default: $default]"
        if ([string]::IsNullOrWhiteSpace($input)) { $input = $default }
        
        try {
            $value = [double]$input
            if ($value -lt $min -or $value -gt $max) {
                Write-Host "Please enter a value between $min and $max" -ForegroundColor Yellow
                $isValid = $false
            } else {
                $isValid = $true
            }
        } catch {
            Write-Host "Please enter a valid number" -ForegroundColor Yellow
            $isValid = $false
        }
    } while (-not $isValid)
    
    return $value
}

# Function to get validated integer input
function Get-ValidatedIntInput {
    param (
        [string]$prompt,
        [int]$min = 0,
        [int]$max = [int]::MaxValue,
        [int]$default = 0
    )
    
    do {
        $input = Read-Host "$prompt [Default: $default]"
        if ([string]::IsNullOrWhiteSpace($input)) { $input = $default }
        
        try {
            $value = [int]$input
            if ($value -lt $min -or $value -gt $max) {
                Write-Host "Please enter a value between $min and $max" -ForegroundColor Yellow
                $isValid = $false
            } else {
                $isValid = $true
            }
        } catch {
            Write-Host "Please enter a valid integer" -ForegroundColor Yellow
            $isValid = $false
        }
    } while (-not $isValid)
    
    return $value
}

# Step 1: Collect information about workload types
Write-Host "Step 1: Define your workload types" -ForegroundColor Green
Write-Host "--------------------------------"

$workloadTypes = @()
$totalWorkloadCpu = 0
$totalWorkloadMemory = 0
$totalPodCount = 0

$workloadTypeCount = Get-ValidatedIntInput "How many different workload types will you deploy?" 1 100 3

for ($i = 1; $i -le $workloadTypeCount; $i++) {
    Write-Host "Workload Type #$i" -ForegroundColor Cyan
    $workloadName = Read-Host "Name of this workload (e.g., 'web-frontend', 'api', 'database')"
    $podCount = Get-ValidatedIntInput "Number of pods for '$workloadName'" 1 1000 3
    $cpuRequest = Get-ValidatedInput "CPU cores requested per pod (cores)" 0.1 64 0.5
    $memoryRequest = Get-ValidatedInput "Memory requested per pod (GB)" 0.25 512 1
    $hasStatefulRequirement = Read-Host "Does this workload have stateful requirements? (y/n) [Default: n]"
    $isStateful = $hasStatefulRequirement -eq "y"
    
    $workloadCpu = $podCount * $cpuRequest
    $workloadMemory = $podCount * $memoryRequest
    
    $totalWorkloadCpu += $workloadCpu
    $totalWorkloadMemory += $workloadMemory
    $totalPodCount += $podCount
    
    $workloadTypes += @{
        Name = $workloadName
        PodCount = $podCount
        CpuPerPod = $cpuRequest
        MemoryPerPod = $memoryRequest
        TotalCpu = $workloadCpu
        TotalMemory = $workloadMemory
        IsStateful = $isStateful
    }
    
    Write-Host "Added '$workloadName': $podCount pods, $workloadCpu total CPU cores, $workloadMemory GB total memory" -ForegroundColor Green
    Write-Host "--------------------------------"
}

# Step 2: Get cluster requirements
Write-Host "Step 2: Define your cluster requirements" -ForegroundColor Green
Write-Host "--------------------------------"

$highAvailability = Read-Host "Do you require high availability for your cluster? (y/n) [Default: y]"
$requiresHA = $highAvailability -ne "n"

$controlPlaneNodeCount = 1
if ($requiresHA) {
    $controlPlaneNodeCount = 3
    Write-Host "For high availability, 3 control plane nodes are recommended."
} else {
    Write-Host "Using a single control plane node (not recommended for production)."
}

$minWorkerNodes = Get-ValidatedIntInput "Minimum number of worker nodes" 1 100 3
if ($minWorkerNodes -lt 2 -and $requiresHA) {
    Write-Host "Warning: For high availability, at least 2 worker nodes are recommended." -ForegroundColor Yellow
    $confirmNodes = Read-Host "Continue with $minWorkerNodes worker node? (y/n) [Default: n]"
    if ($confirmNodes -ne "y") {
        $minWorkerNodes = 2
        Write-Host "Using 2 worker nodes for high availability."
    }
}

# Calculate HA factor based on the N+1 formula
$haFactor = if ($requiresHA) { ($minWorkerNodes + 1) / $minWorkerNodes } else { 1.0 }
Write-Host "High availability factor: $haFactor"

# Step 3: Get hardware constraints
Write-Host "Step 3: Define host hardware constraints" -ForegroundColor Green
Write-Host "--------------------------------"

$cpuPerNode = Get-ValidatedInput "Available CPU cores per worker node" 1 128 8
$memoryPerNode = Get-ValidatedInput "Available memory per worker node (GB)" 4 1024 32
$controlPlaneCpuPerNode = Get-ValidatedInput "Available CPU cores per control plane node" 1 128 4
$controlPlaneMemoryPerNode = Get-ValidatedInput "Available memory per control plane node (GB)" 4 1024 16

# Calculate resource requirements

# Calculate required resources with system overhead
$requiredCpuWithOverhead = $totalWorkloadCpu * (1 + $overheadFactor)
$requiredMemoryWithOverhead = $totalWorkloadMemory * (1 + $overheadFactor)

# Add control plane resources
$controlPlaneCpu = $controlPlaneNodeCount * 2  # 2 vCPUs per control plane node
$controlPlaneMemory = $controlPlaneNodeCount * 4  # 4 GB per control plane node

# Add Arc components
$arcResourceCpu = $totalWorkloadCpu * $arcOverhead
$arcResourceMemory = $totalWorkloadMemory * $arcOverhead

# Apply HA factor to worker resources
$haAdjustedCpu = $requiredCpuWithOverhead * $haFactor
$haAdjustedMemory = $requiredMemoryWithOverhead * $haFactor

# Total required cluster CPU and Memory
$totalRequiredCpu = $haAdjustedCpu + $controlPlaneCpu + $arcResourceCpu
$totalRequiredMemory = $haAdjustedMemory + $controlPlaneMemory + $arcResourceMemory

# Calculate required nodes based on available resources and target utilization
$requiredWorkerNodesForCpu = [math]::Ceiling($haAdjustedCpu / ($cpuPerNode * $targetUtilization))
$requiredWorkerNodesForMemory = [math]::Ceiling($haAdjustedMemory / ($memoryPerNode * $targetUtilization))
$requiredWorkerNodes = [math]::Max($requiredWorkerNodesForCpu, $requiredWorkerNodesForMemory)
$requiredWorkerNodes = [math]::Max($requiredWorkerNodes, $minWorkerNodes)

# Calculate host requirements including overhead
$totalVmCpu = ($requiredWorkerNodes * $cpuPerNode) + ($controlPlaneNodeCount * $controlPlaneCpuPerNode)
$totalVmMemory = ($requiredWorkerNodes * $memoryPerNode) + ($controlPlaneNodeCount * $controlPlaneMemoryPerNode)

$totalPhysicalCpu = $totalVmCpu / (1 - $hostOsOverhead - $vmOverhead)
$totalPhysicalMemory = $totalVmMemory / (1 - $hostOsOverhead - $vmOverhead)

# Calculate storage requirements
$storagePerControlPlaneNode = 128  # GB
$dataStoragePerWorkerNode = 256    # GB, baseline
$osStoragePerWorkerNode = 128      # GB

# Adjust storage for stateful workloads
$statefulWorkloads = $workloadTypes | Where-Object { $_.IsStateful -eq $true }
$additionalDataStorage = 0
foreach ($workload in $statefulWorkloads) {
    $additionalDataStorage += $workload.TotalMemory * 4  # Estimate 4x memory for stateful workloads
}

$totalControlPlaneStorage = $controlPlaneNodeCount * $storagePerControlPlaneNode
$totalWorkerOsStorage = $requiredWorkerNodes * $osStoragePerWorkerNode
$totalWorkerDataStorage = ($requiredWorkerNodes * $dataStoragePerWorkerNode) + $additionalDataStorage
$totalStorageRequired = $totalControlPlaneStorage + $totalWorkerOsStorage + $totalWorkerDataStorage

# Output the results
Clear-Host
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host "  Azure Local Kubernetes Sizing Results" -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Workload Summary:" -ForegroundColor Green
Write-Host "--------------------------------"
Write-Host "Total Application Pods: $totalPodCount"
Write-Host "Raw Application CPU Requirements: $($totalWorkloadCpu.ToString("0.00")) cores"
Write-Host "Raw Application Memory Requirements: $($totalWorkloadMemory.ToString("0.00")) GB"
Write-Host ""

Write-Host "Cluster Architecture:" -ForegroundColor Green
Write-Host "--------------------------------"
Write-Host "High Availability: $(if ($requiresHA) { 'Yes' } else { 'No' })"
Write-Host "Control Plane Nodes: $controlPlaneNodeCount"
Write-Host "Worker Nodes Required: $requiredWorkerNodes"
Write-Host "Total Node Count: $($controlPlaneNodeCount + $requiredWorkerNodes)"
Write-Host ""

Write-Host "Virtual Machine Requirements:" -ForegroundColor Green
Write-Host "--------------------------------"
Write-Host "Control Plane VM Specs: $($controlPlaneCpuPerNode) vCPU, $($controlPlaneMemoryPerNode) GB RAM per node"
Write-Host "Worker VM Specs: $($cpuPerNode) vCPU, $($memoryPerNode) GB RAM per node"
Write-Host "Total VM CPU: $($totalVmCpu.ToString("0.00")) vCPU cores"
Write-Host "Total VM Memory: $($totalVmMemory.ToString("0.00")) GB"
Write-Host ""

Write-Host "Physical Host Requirements:" -ForegroundColor Green
Write-Host "--------------------------------"
Write-Host "Minimum Physical CPU: $($totalPhysicalCpu.ToString("0.00")) cores"
Write-Host "Minimum Physical Memory: $($totalPhysicalMemory.ToString("0.00")) GB"
Write-Host ""

Write-Host "Storage Requirements:" -ForegroundColor Green
Write-Host "--------------------------------"
Write-Host "Control Plane Storage: $totalControlPlaneStorage GB"
Write-Host "Worker OS Storage: $totalWorkerOsStorage GB"
Write-Host "Worker Data Storage: $($totalWorkerDataStorage.ToString("0.00")) GB"
Write-Host "Total Storage Required: $($totalStorageRequired.ToString("0.00")) GB"
Write-Host ""

Write-Host "Recommended Azure Local Configuration:" -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host "Control Plane VM Size: $($controlPlaneCpuPerNode) vCPU, $($controlPlaneMemoryPerNode)GB RAM"
Write-Host "Worker VM Size: $($cpuPerNode) vCPU, $($memoryPerNode)GB RAM"
Write-Host "Total Host Capacity Needed: $($totalPhysicalCpu.ToString("0.00")) CPU cores, $($totalPhysicalMemory.ToString("0.00"))GB RAM"
Write-Host "Storage Pool Size: $($totalStorageRequired.ToString("0.00"))GB"
Write-Host ""

Write-Host "NOTE: This is an estimate. Actual requirements may vary based on workload characteristics."
Write-Host "Consider factors such as network I/O, disk I/O, and specific application needs when finalizing sizing."

# Option to save results to a file
$saveToFile = Read-Host "Would you like to save these results to a file? (y/n) [Default: y]"
if ($saveToFile -ne "n") {
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $outputFile = "AzureLocalK8sSizing_$timestamp.txt"
    
    "====================================================" | Out-File $outputFile
    "  Azure Local Kubernetes Sizing Results" | Out-File $outputFile -Append
    "====================================================" | Out-File $outputFile -Append
    "" | Out-File $outputFile -Append
    
    "Workload Summary:" | Out-File $outputFile -Append
    "--------------------------------" | Out-File $outputFile -Append
    "Total Application Pods: $totalPodCount" | Out-File $outputFile -Append
    "Raw Application CPU Requirements: $($totalWorkloadCpu.ToString("0.00")) cores" | Out-File $outputFile -Append
    "Raw Application Memory Requirements: $($totalWorkloadMemory.ToString("0.00")) GB" | Out-File $outputFile -Append
    "" | Out-File $outputFile -Append
    
    "Cluster Architecture:" | Out-File $outputFile -Append
    "--------------------------------" | Out-File $outputFile -Append
    "High Availability: $(if ($requiresHA) { 'Yes' } else { 'No' })" | Out-File $outputFile -Append
    "Control Plane Nodes: $controlPlaneNodeCount" | Out-File $outputFile -Append
    "Worker Nodes Required: $requiredWorkerNodes" | Out-File $outputFile -Append
    "Total Node Count: $($controlPlaneNodeCount + $requiredWorkerNodes)" | Out-File $outputFile -Append
    "" | Out-File $outputFile -Append
    
    "Virtual Machine Requirements:" | Out-File $outputFile -Append
    "--------------------------------" | Out-File $outputFile -Append
    "Control Plane VM Specs: $($controlPlaneCpuPerNode) vCPU, $($controlPlaneMemoryPerNode) GB RAM per node" | Out-File $outputFile -Append
    "Worker VM Specs: $($cpuPerNode) vCPU, $($memoryPerNode) GB RAM per node" | Out-File $outputFile -Append
    "Total VM CPU: $($totalVmCpu.ToString("0.00")) vCPU cores" | Out-File $outputFile -Append
    "Total VM Memory: $($totalVmMemory.ToString("0.00")) GB" | Out-File $outputFile -Append
    "" | Out-File $outputFile -Append
    
    "Physical Host Requirements:" | Out-File $outputFile -Append
    "--------------------------------" | Out-File $outputFile -Append
    "Minimum Physical CPU: $($totalPhysicalCpu.ToString("0.00")) cores" | Out-File $outputFile -Append
    "Minimum Physical Memory: $($totalPhysicalMemory.ToString("0.00")) GB" | Out-File $outputFile -Append
    "" | Out-File $outputFile -Append
    
    "Storage Requirements:" | Out-File $outputFile -Append
    "--------------------------------" | Out-File $outputFile -Append
    "Control Plane Storage: $totalControlPlaneStorage GB" | Out-File $outputFile -Append
    "Worker OS Storage: $totalWorkerOsStorage GB" | Out-File $outputFile -Append
    "Worker Data Storage: $($totalWorkerDataStorage.ToString("0.00")) GB" | Out-File $outputFile -Append
    "Total Storage Required: $($totalStorageRequired.ToString("0.00")) GB" | Out-File $outputFile -Append
    "" | Out-File $outputFile -Append
    
    "Recommended Azure Local Configuration:" | Out-File $outputFile -Append
    "====================================================" | Out-File $outputFile -Append
    "Control Plane VM Size: $($controlPlaneCpuPerNode) vCPU, $($controlPlaneMemoryPerNode)GB RAM" | Out-File $outputFile -Append
    "Worker VM Size: $($cpuPerNode) vCPU, $($memoryPerNode)GB RAM" | Out-File $outputFile -Append
    "Total Host Capacity Needed: $($totalPhysicalCpu.ToString("0.00")) CPU cores, $($totalPhysicalMemory.ToString("0.00"))GB RAM" | Out-File $outputFile -Append
    "Storage Pool Size: $($totalStorageRequired.ToString("0.00"))GB" | Out-File $outputFile -Append
    "" | Out-File $outputFile -Append
    
    "NOTE: This is an estimate. Actual requirements may vary based on workload characteristics." | Out-File $outputFile -Append
    "Consider factors such as network I/O, disk I/O, and specific application needs when finalizing sizing." | Out-File $outputFile -Append
    
    Write-Host "Results saved to: $outputFile" -ForegroundColor Green
}

Write-Host "Thank you for using the Azure Local Kubernetes Sizing Calculator!"
