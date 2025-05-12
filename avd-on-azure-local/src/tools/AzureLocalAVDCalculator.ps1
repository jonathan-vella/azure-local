# AzureLocalAVDCalculator.ps1
# PowerShell calculator for sizing Azure Virtual Desktop on Azure Local
# This script helps determine the right size for AVD deployments running on Azure Local
# by calculating resource requirements based on user profiles and applying best practices.

# Clear the screen and display welcome message
Clear-Host
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host "  Azure Local Virtual Desktop Sizing Calculator" -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host "This tool will help you right-size your Azure Virtual Desktop deployment on Azure Local."
Write-Host "Please provide the requested information about your user profiles and requirements."
Write-Host ""

# Initialize variables with default values
$concurrencyFactor = 0.7 # 70% concurrent users at peak
$haFactor = 0 # Will be calculated based on session hosts
$hostOsOverhead = 0.1 # 10% for host OS
$vmOverhead = 0.05 # 5% for VM hypervisor
$windowsOverheadCpu = 2 # 2 vCPUs for Windows OS
$windowsOverheadMemory = 4 # 4 GB for Windows OS

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

# Step 1: Collect information about user types
Write-Host "Step 1: Define your user profiles" -ForegroundColor Green
Write-Host "--------------------------------"

$userProfiles = @()
$totalUserCount = 0
$totalRawCpu = 0
$totalRawMemory = 0

$userProfileTypes = @(
    @{Name = "Light Knowledge Worker"; DefaultVCpu = 2; DefaultMemory = 8; DefaultOversubscription = 6},
    @{Name = "Medium Knowledge Worker"; DefaultVCpu = 4; DefaultMemory = 16; DefaultOversubscription = 4},
    @{Name = "Power User"; DefaultVCpu = 8; DefaultMemory = 32; DefaultOversubscription = 2},
    @{Name = "Graphics Intensive User"; DefaultVCpu = 8; DefaultMemory = 32; DefaultOversubscription = 1}
)

foreach ($profileType in $userProfileTypes) {
    Write-Host "User Profile: $($profileType.Name)" -ForegroundColor Cyan
    $userCount = Get-ValidatedIntInput "Number of $($profileType.Name) users" 0 10000 10
    
    if ($userCount -gt 0) {
        $vcpuPerUser = Get-ValidatedInput "vCPU cores per user" 1 16 $profileType.DefaultVCpu
        $memoryPerUser = Get-ValidatedInput "Memory per user (GB)" 2 128 $profileType.DefaultMemory
        $oversubscriptionRatio = Get-ValidatedInput "CPU oversubscription ratio (physical:virtual)" 1 10 $profileType.DefaultOversubscription
        
        $profileVCpu = $userCount * $vcpuPerUser
        $profileMemory = $userCount * $memoryPerUser
        
        $totalUserCount += $userCount
        $totalRawCpu += $profileVCpu
        $totalRawMemory += $profileMemory
        
        $userProfiles += @{
            Name = $profileType.Name
            UserCount = $userCount
            VCpuPerUser = $vcpuPerUser
            MemoryPerUser = $memoryPerUser
            TotalVCpu = $profileVCpu
            TotalMemory = $profileMemory
            OversubscriptionRatio = $oversubscriptionRatio
        }
        
        Write-Host "Added $userCount $($profileType.Name) users requiring $profileVCpu total vCPU cores and $profileMemory GB total memory" -ForegroundColor Green
        Write-Host "--------------------------------"
    }
}

if ($totalUserCount -eq 0) {
    Write-Host "Error: You must define at least one user profile with users." -ForegroundColor Red
    exit
}

# Step 2: Get concurrency and session host requirements
Write-Host "Step 2: Define session patterns and requirements" -ForegroundColor Green
Write-Host "--------------------------------"

$concurrencyFactor = Get-ValidatedInput "Peak concurrency factor (percentage of users online simultaneously)" 0.1 1.0 0.7
$concurrencyFactor = [Math]::Round($concurrencyFactor, 2)
Write-Host "Using peak concurrency of $($concurrencyFactor * 100)%"

# Calculate concurrent resources
$concurrentVCpu = $totalRawCpu * $concurrencyFactor
$concurrentMemory = $totalRawMemory * $concurrencyFactor

# Calculate physical CPU cores needed based on oversubscription
$physicalCpuRequired = 0
foreach ($profile in $userProfiles) {
    $profileConcurrentUsers = $profile.UserCount * $concurrencyFactor
    $profileConcurrentVCpu = $profileConcurrentUsers * $profile.VCpuPerUser
    $profilePhysicalCpu = $profileConcurrentVCpu / $profile.OversubscriptionRatio
    $physicalCpuRequired += $profilePhysicalCpu
}

# HA requirements
$highAvailability = Read-Host "Do you require high availability for your deployment? (y/n) [Default: y]"
$requiresHA = $highAvailability -ne "n"

# Session host specifications
Write-Host "Step 3: Define session host specifications" -ForegroundColor Green
Write-Host "--------------------------------"

$vcpuPerSessionHost = Get-ValidatedInput "Maximum vCPU cores per session host VM" 2 128 16
$memoryPerSessionHost = Get-ValidatedInput "Maximum memory per session host VM (GB)" 8 1024 64

# Calculate number of session hosts needed
$sessionHostsForCpu = [Math]::Ceiling(($concurrentVCpu + $windowsOverheadCpu) / $vcpuPerSessionHost)
$sessionHostsForMemory = [Math]::Ceiling(($concurrentMemory + $windowsOverheadMemory) / $memoryPerSessionHost)
$requiredSessionHosts = [Math]::Max($sessionHostsForCpu, $sessionHostsForMemory)

# Apply HA factor if needed
if ($requiresHA) {
    $minSessionHosts = Get-ValidatedIntInput "Minimum number of session hosts" 2 100 3
    $requiredSessionHosts = [Math]::Max($requiredSessionHosts, $minSessionHosts)
    $haFactor = ($requiredSessionHosts + 1) / $requiredSessionHosts
    $requiredSessionHosts += 1  # N+1 redundancy
    Write-Host "For high availability, using N+1 redundancy with $requiredSessionHosts session hosts"
} else {
    $haFactor = 1.0
    Write-Host "No high availability redundancy applied"
}

# Step 4: Storage requirements
Write-Host "Step 4: Define storage requirements" -ForegroundColor Green
Write-Host "--------------------------------"

$userProfileSize = Get-ValidatedInput "Average FSLogix profile size per user (GB)" 1 100 20
$sharedAppStorage = Get-ValidatedInput "Shared application storage (GB)" 0 10000 200
$osDiskSize = Get-ValidatedInput "OS disk size per session host (GB)" 64 1024 128

$totalProfileStorage = $totalUserCount * $userProfileSize
$profileStorageWithGrowth = $totalProfileStorage * 1.3  # 30% growth factor
$totalOsDiskStorage = $requiredSessionHosts * $osDiskSize
$totalAppStorage = $sharedAppStorage + ($totalUserCount * 10)  # 10GB per user for application cache and data

$totalStorageRequired = $profileStorageWithGrowth + $totalOsDiskStorage + $totalAppStorage

# Step 5: Network requirements
Write-Host "Step 5: Define network requirements" -ForegroundColor Green
Write-Host "--------------------------------"

$bandwidthPerUser = Get-ValidatedInput "Average bandwidth per concurrent user (Mbps)" 0.5 10 2
$concurrentUsers = $totalUserCount * $concurrencyFactor
$totalBandwidth = $concurrentUsers * $bandwidthPerUser
$totalBandwidthWithOverhead = $totalBandwidth * 1.3  # 30% overhead

# Calculate physical host requirements
$totalVmCpu = ($requiredSessionHosts * $vcpuPerSessionHost)
$totalVmMemory = ($requiredSessionHosts * $memoryPerSessionHost)

$totalPhysicalCpu = $physicalCpuRequired * $haFactor  # Add HA factor to physical CPU
$totalPhysicalMemory = $totalVmMemory / (1 - $hostOsOverhead - $vmOverhead)

# Output the results
Clear-Host
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host "  Azure Local Virtual Desktop Sizing Results" -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "User Profile Summary:" -ForegroundColor Green
Write-Host "--------------------------------"
Write-Host "Total Users: $totalUserCount"
foreach ($profile in $userProfiles) {
    Write-Host "$($profile.Name): $($profile.UserCount) users, $($profile.VCpuPerUser) vCPU/user, $($profile.MemoryPerUser)GB RAM/user"
}
Write-Host "Peak Concurrency: $($concurrencyFactor * 100)% ($([Math]::Round($concurrentUsers)) concurrent users)"
Write-Host ""

Write-Host "Resource Requirements:" -ForegroundColor Green
Write-Host "--------------------------------"
Write-Host "Total Raw vCPU Requirement: $($totalRawCpu.ToString("0.00")) vCPU cores"
Write-Host "Total Raw Memory Requirement: $($totalRawMemory.ToString("0.00")) GB"
Write-Host "Concurrent vCPU Requirement: $($concurrentVCpu.ToString("0.00")) vCPU cores"
Write-Host "Concurrent Memory Requirement: $($concurrentMemory.ToString("0.00")) GB"
Write-Host "Physical CPU Cores Required (with oversubscription): $($physicalCpuRequired.ToString("0.00")) cores"
Write-Host "Physical CPU Cores Required (with HA factor): $($totalPhysicalCpu.ToString("0.00")) cores"
Write-Host ""

Write-Host "Session Host Architecture:" -ForegroundColor Green
Write-Host "--------------------------------"
Write-Host "High Availability: $(if ($requiresHA) { 'Yes (N+1 redundancy)' } else { 'No' })"
Write-Host "Session Host Size: $vcpuPerSessionHost vCPU, $memoryPerSessionHost GB RAM"
Write-Host "Session Hosts Required: $requiredSessionHosts"
Write-Host ""

Write-Host "Storage Requirements:" -ForegroundColor Green
Write-Host "--------------------------------"
Write-Host "User Profile Storage: $($profileStorageWithGrowth.ToString("0.00")) GB (includes 30% growth)"
Write-Host "Session Host OS Storage: $totalOsDiskStorage GB"
Write-Host "Application and Shared Storage: $($totalAppStorage.ToString("0.00")) GB"
Write-Host "Total Storage Required: $($totalStorageRequired.ToString("0.00")) GB"
Write-Host ""

Write-Host "Network Requirements:" -ForegroundColor Green
Write-Host "--------------------------------"
Write-Host "Bandwidth per Concurrent User: $bandwidthPerUser Mbps"
Write-Host "Total Internet Bandwidth Required: $($totalBandwidthWithOverhead.ToString("0.00")) Mbps (includes 30% overhead)"
Write-Host "Recommended Internal Network: 10 Gbps between hosts and storage"
Write-Host ""

Write-Host "Physical Host Requirements:" -ForegroundColor Green
Write-Host "--------------------------------"
Write-Host "Recommended Physical CPU: $($totalPhysicalCpu.ToString("0.00")) cores"
Write-Host "Recommended Physical Memory: $($totalPhysicalMemory.ToString("0.00")) GB"
Write-Host ""

Write-Host "Recommended Azure Local Configuration:" -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan

# Calculate recommended number of physical hosts based on typical Azure Stack HCI configurations
$coresPerPhysicalHost = 16  # Assuming typical server with 16-32 cores
$memoryPerPhysicalHost = 256  # Assuming typical server with 256-512 GB RAM

$hostsForCpu = [Math]::Ceiling($totalPhysicalCpu / $coresPerPhysicalHost)
$hostsForMemory = [Math]::Ceiling($totalPhysicalMemory / $memoryPerPhysicalHost)
$recommendedHostCount = [Math]::Max($hostsForCpu, $hostsForMemory)

Write-Host "Session Host VM Size: $vcpuPerSessionHost vCPU, $($memoryPerSessionHost)GB RAM"
Write-Host "Number of Session Hosts: $requiredSessionHosts"
Write-Host "Recommended Physical Hosts: $recommendedHostCount (assuming $coresPerPhysicalHost cores, $memoryPerPhysicalHost GB RAM per host)"
Write-Host "Total Host Capacity Needed: $($totalPhysicalCpu.ToString("0.00")) CPU cores, $($totalPhysicalMemory.ToString("0.00"))GB RAM"
Write-Host "Storage Pool Size: $($totalStorageRequired.ToString("0.00"))GB"
Write-Host ""

Write-Host "NOTE: This is an estimate. Actual requirements may vary based on user behavior and application needs."
Write-Host "Consider factors such as login storms, application performance requirements, and specific user needs when finalizing sizing."

# Option to save results to a file
$saveToFile = Read-Host "Would you like to save these results to a file? (y/n) [Default: y]"
if ($saveToFile -ne "n") {
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $outputFile = "AzureLocalAVDSizing_$timestamp.txt"
    
    "====================================================" | Out-File $outputFile
    "  Azure Local Virtual Desktop Sizing Results" | Out-File $outputFile -Append
    "====================================================" | Out-File $outputFile -Append
    "" | Out-File $outputFile -Append
    
    "User Profile Summary:" | Out-File $outputFile -Append
    "--------------------------------" | Out-File $outputFile -Append
    "Total Users: $totalUserCount" | Out-File $outputFile -Append
    foreach ($profile in $userProfiles) {
        "$($profile.Name): $($profile.UserCount) users, $($profile.VCpuPerUser) vCPU/user, $($profile.MemoryPerUser)GB RAM/user" | Out-File $outputFile -Append
    }
    "Peak Concurrency: $($concurrencyFactor * 100)% ($([Math]::Round($concurrentUsers)) concurrent users)" | Out-File $outputFile -Append
    "" | Out-File $outputFile -Append
    
    "Resource Requirements:" | Out-File $outputFile -Append
    "--------------------------------" | Out-File $outputFile -Append
    "Total Raw vCPU Requirement: $($totalRawCpu.ToString("0.00")) vCPU cores" | Out-File $outputFile -Append
    "Total Raw Memory Requirement: $($totalRawMemory.ToString("0.00")) GB" | Out-File $outputFile -Append
    "Concurrent vCPU Requirement: $($concurrentVCpu.ToString("0.00")) vCPU cores" | Out-File $outputFile -Append
    "Concurrent Memory Requirement: $($concurrentMemory.ToString("0.00")) GB" | Out-File $outputFile -Append
    "Physical CPU Cores Required (with oversubscription): $($physicalCpuRequired.ToString("0.00")) cores" | Out-File $outputFile -Append
    "Physical CPU Cores Required (with HA factor): $($totalPhysicalCpu.ToString("0.00")) cores" | Out-File $outputFile -Append
    "" | Out-File $outputFile -Append
    
    "Session Host Architecture:" | Out-File $outputFile -Append
    "--------------------------------" | Out-File $outputFile -Append
    "High Availability: $(if ($requiresHA) { 'Yes (N+1 redundancy)' } else { 'No' })" | Out-File $outputFile -Append
    "Session Host Size: $vcpuPerSessionHost vCPU, $memoryPerSessionHost GB RAM" | Out-File $outputFile -Append
    "Session Hosts Required: $requiredSessionHosts" | Out-File $outputFile -Append
    "" | Out-File $outputFile -Append
    
    "Storage Requirements:" | Out-File $outputFile -Append
    "--------------------------------" | Out-File $outputFile -Append
    "User Profile Storage: $($profileStorageWithGrowth.ToString("0.00")) GB (includes 30% growth)" | Out-File $outputFile -Append
    "Session Host OS Storage: $totalOsDiskStorage GB" | Out-File $outputFile -Append
    "Application and Shared Storage: $($totalAppStorage.ToString("0.00")) GB" | Out-File $outputFile -Append
    "Total Storage Required: $($totalStorageRequired.ToString("0.00")) GB" | Out-File $outputFile -Append
    "" | Out-File $outputFile -Append
    
    "Network Requirements:" | Out-File $outputFile -Append
    "--------------------------------" | Out-File $outputFile -Append
    "Bandwidth per Concurrent User: $bandwidthPerUser Mbps" | Out-File $outputFile -Append
    "Total Internet Bandwidth Required: $($totalBandwidthWithOverhead.ToString("0.00")) Mbps (includes 30% overhead)" | Out-File $outputFile -Append
    "Recommended Internal Network: 10 Gbps between hosts and storage" | Out-File $outputFile -Append
    "" | Out-File $outputFile -Append
    
    "Physical Host Requirements:" | Out-File $outputFile -Append
    "--------------------------------" | Out-File $outputFile -Append
    "Recommended Physical CPU: $($totalPhysicalCpu.ToString("0.00")) cores" | Out-File $outputFile -Append
    "Recommended Physical Memory: $($totalPhysicalMemory.ToString("0.00")) GB" | Out-File $outputFile -Append
    "" | Out-File $outputFile -Append
    
    "Recommended Azure Local Configuration:" | Out-File $outputFile -Append
    "====================================================" | Out-File $outputFile -Append
    "Session Host VM Size: $vcpuPerSessionHost vCPU, $($memoryPerSessionHost)GB RAM" | Out-File $outputFile -Append
    "Number of Session Hosts: $requiredSessionHosts" | Out-File $outputFile -Append
    "Recommended Physical Hosts: $recommendedHostCount (assuming $coresPerPhysicalHost cores, $memoryPerPhysicalHost GB RAM per host)" | Out-File $outputFile -Append
    "Total Host Capacity Needed: $($totalPhysicalCpu.ToString("0.00")) CPU cores, $($totalPhysicalMemory.ToString("0.00"))GB RAM" | Out-File $outputFile -Append
    "Storage Pool Size: $($totalStorageRequired.ToString("0.00"))GB" | Out-File $outputFile -Append
    "" | Out-File $outputFile -Append
    
    "NOTE: This is an estimate. Actual requirements may vary based on user behavior and application needs." | Out-File $outputFile -Append
    "Consider factors such as login storms, application performance requirements, and specific user needs when finalizing sizing." | Out-File $outputFile -Append
    
    Write-Host "Results saved to: $outputFile" -ForegroundColor Green
}

Write-Host "Thank you for using the Azure Local Virtual Desktop Sizing Calculator!"
