# Sizing Examples for Azure Virtual Desktop on Azure Local

## Example 1: Small Business Deployment
- **User Profile**: 25 light knowledge workers, 5 medium knowledge workers
- **User Patterns**: 9-5 work hours, 70% peak concurrency
- **Resource Requirements**: 12 vCPU, 48GB RAM (concurrent)
- **Recommended Configuration**: 
  - 2 physical hosts (16 cores, 128GB RAM each)
  - 2-way mirror Storage Spaces Direct
  - 3 session hosts (4 vCPU, 16GB RAM each)

## Example 2: Medium Enterprise Deployment
- **User Profile**: 75 light users, 50 medium users, 25 power users
- **User Patterns**: 24x7 operations, 80% peak concurrency
- **Resource Requirements**: 60 vCPU, 240GB RAM (concurrent)
- **Recommended Configuration**:
  - 4 physical hosts (24 cores, 256GB RAM each)
  - 3-way mirror Storage Spaces Direct
  - 8 session hosts (8 vCPU, 32GB RAM each)

## Example 3: Using the PowerShell Calculator for Financial Services Firm

This example demonstrates using the [Azure Local Virtual Desktop PowerShell Calculator](../tools/AzureLocalAVDCalculator.ps1) to size a production VDI deployment for a financial services firm.

### Input Parameters

When running the calculator for this scenario, the following inputs were provided:

**User Profiles:**
1. **Light Knowledge Workers**
   - Users: 50
   - vCPU per user: 2
   - Memory per user: 8 GB
   - Oversubscription ratio: 6:1

2. **Medium Knowledge Workers**
   - Users: 30
   - vCPU per user: 4
   - Memory per user: 16 GB
   - Oversubscription ratio: 4:1

3. **Power Users (Financial Analysts)**
   - Users: 20
   - vCPU per user: 8
   - Memory per user: 32 GB
   - Oversubscription ratio: 2:1

**Session Patterns**: 75% peak concurrency  
**High Availability**: Yes (N+1 redundancy)  
**Session Host VM Size**: 16 vCPU, 64GB RAM  
**User Profile Storage**: 25GB per user  
**Shared Application Storage**: 500GB  
**Bandwidth Per User**: 2 Mbps

### Calculator Results

The PowerShell Calculator provided the following results:

**User Profile Summary:**
- Total Users: 100
- Peak Concurrency: 75% (75 concurrent users)

**Resource Requirements:**
- Total Raw vCPU Requirement: 340.00 vCPU cores
- Total Raw Memory Requirement: 1280.00 GB
- Concurrent vCPU Requirement: 255.00 vCPU cores
- Concurrent Memory Requirement: 960.00 GB
- Physical CPU Cores Required (with oversubscription): 75.00 cores
- Physical CPU Cores Required (with HA factor): 87.50 cores

**Session Host Architecture:**
- High Availability: Yes (N+1 redundancy)
- Session Host Size: 16 vCPU, 64 GB RAM
- Session Hosts Required: 18

**Storage Requirements:**
- User Profile Storage: 3250.00 GB (includes 30% growth)
- Session Host OS Storage: 2304 GB
- Application and Shared Storage: 1500.00 GB
- Total Storage Required: 7054.00 GB

**Network Requirements:**
- Bandwidth per Concurrent User: 2 Mbps
- Total Internet Bandwidth Required: 195.00 Mbps (includes 30% overhead)

**Physical Host Requirements:**
- Recommended Physical CPU: 87.50 cores
- Recommended Physical Memory: 1265.82 GB

**Recommended Azure Local Configuration:**
- Session Host VM Size: 16 vCPU, 64GB RAM
- Number of Session Hosts: 18
- Recommended Physical Hosts: 6 (assuming 16 cores, 256 GB RAM per host)
- Total Host Capacity Needed: 87.50 CPU cores, 1265.82GB RAM
- Storage Pool Size: 7054.00GB

### Implementation Decision

Based on these calculations, the organization deployed 6 physical hosts with 20 cores and 320GB RAM each, totaling 120 cores and 1920GB RAM, which provides sufficient capacity plus room for future growth.
