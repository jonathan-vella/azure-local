# Capacity Planning for Azure Local Virtual Desktop

## Capacity Planning Worksheet

### Step 1: User Profile Analysis
1. List each user type and count: (Example: 50 light users, 30 medium users, 20 power users)
2. Document resource requirements per user type:
   - Light users: 2 vCPU, 8GB RAM
   - Medium users: 4 vCPU, 16GB RAM
   - Power users: 8 vCPU, 32GB RAM
3. Calculate total: (50×2 + 30×4 + 20×8) = 300 vCPU cores, (50×8 + 30×16 + 20×32) = 1,440GB RAM

### Step 2: Apply Concurrency Factor
- Determine peak concurrent usage: Example: 70% peak concurrency
- Adjust resource requirements: 300 vCPU × 0.7 = 210 vCPU, 1,440GB RAM × 0.7 = 1,008GB RAM

### Step 3: Apply Oversubscription Ratio
- Determine appropriate oversubscription ratio based on user mix
- Example: Mixed user types average 5:1 ratio
- Calculate physical cores needed: 210 vCPU ÷ 5 = 42 physical CPU cores

### Step 4: Apply High-Availability Factor
- Ensure capacity when one host fails: Multiply by N+1/N
- For a deployment with 6 session hosts: × 7/6 = 1.17 factor
- Adjusted resources: 42 physical cores × 1.17 = 49.14 cores (round up to 50 cores)

### Step 5: Storage Calculations
- OS disk: Number of session hosts × 128GB
- User profiles: Number of users × average profile size (Example: 100 users × 20GB = 2TB)
- Applications and shared content: Base estimate + per user allocation (Example: 200GB + 100 users × 10GB = 1.2TB)

### Step 6: Determine Host Count and Specifications
- Divide total required resources by resources per host
- Consider standard Azure Local host sizes (optimize for your hardware)
- Example: If using hosts with 8 physical cores (16 vCPU with hyperthreading) and 128GB RAM:
  50 physical cores ÷ 8 cores per host = 6.25 (round up to 7 hosts)

### Step 7: Network Bandwidth Planning
- Internet: Concurrent users × per-user bandwidth × overhead factor
- Internal network: Plan for 10Gbps between hosts and storage
- Consider redundancy requirements for network paths

## Capacity Planning Tool
For more detailed calculations, use the [PowerShell Sizing Calculator](../tools/AzureLocalAVDCalculator.ps1) included in the tools section.
