# Capacity Planning for Azure Arc-enabled SQL Managed Instance on Azure Local

## Service Tier Selection

Begin your capacity planning by determining the appropriate service tier for your workload:

| Feature | General Purpose | Business Critical |
|---------|----------------|-------------------|
| Compute | Shared compute resources | Dedicated compute resources |
| Storage | Remote storage | Local storage with HA replication |
| High Availability | Depends on Kubernetes and storage | Built-in Always On Availability Groups |
| Performance | Good performance for most workloads | Highest performance and lowest latency |
| Best for | Dev/test, small to medium production | Mission-critical, high-performance needs |

## Capacity Planning Worksheet

### Step 1: Analyze Database Workload
1. Database size and growth rate:
   - Current data size: _____ GB
   - Annual growth rate: _____% per year
   - Projected size after 3 years: _____ GB

2. Transaction activity:
   - Peak transactions per second: _____
   - Average batch requests per second: _____
   - Read/write ratio: _____

3. Query characteristics:
   - Predominantly OLTP, OLAP, or mixed: _____
   - Peak concurrent queries: _____
   - Average query complexity (simple, moderate, complex): _____
   - Max degree of parallelism required: _____

4. User activity:
   - Peak concurrent users: _____
   - Average connection count: _____
   - Connection spike patterns: _____

### Step 2: Select Service Tier and Determine SQL MI Resources
- **Choose Service Tier**:
  - [ ] General Purpose (remote storage, good for most workloads)
  - [ ] Business Critical (local storage, high performance, built-in HA)

- **Calculate CPU Requirements**:
  - For General Purpose:
    - Minimum: 1 vCore, Maximum: 24 vCores
    - For OLTP: (Peak batch requests/second ÷ 2000) × complexity factor = _____ vCPUs
    - For OLAP: (Peak concurrent queries × typical parallelism) = _____ vCPUs
    - For mixed: Higher of OLTP or OLAP requirements = _____ vCPUs
    - Add 20% overhead for SQL MI background processes = _____ total vCPUs

  - For Business Critical:
    - Minimum: 3 vCores (no maximum)
    - CPU requirements from above: _____ vCPUs
    - For HA: multiply by number of replicas (typically 3) for total cluster requirements

### Step 3: Calculate Memory Requirements
- For General Purpose:
  - Minimum: 2 GB, Maximum: 128 GB
  - Buffer pool target: (Database size × 0.7) = _____ GB
  - SQL Server overhead: 2-4 GB
  - Total memory request: _____ GB

- For Business Critical:
  - Minimum: 2 GB (no maximum)
  - Buffer pool target: (Database size × 0.7) = _____ GB
  - SQL Server overhead: 4-8 GB
  - For HA: multiply by number of replicas (typically 3) for total cluster requirements
  - Total memory request: _____ GB

### Step 4: Calculate Storage Requirements
- Data volume: (Current size × (1 + annual growth × 3) × 1.2) = _____ GB
- Log volume: (For full recovery: 25-30% of data size) = _____ GB
- For Business Critical tier: Multiple by 3 for replicas = _____ GB
- Total storage capacity: _____ GB

### Step 5: Calculate Storage Performance Requirements

- **For General Purpose tier**:
  - Data IOPS: (Peak users × 10 IOPS per user) = _____ IOPS
  - Log IOPS: (Peak TPS × 5) = _____ IOPS
  - Storage classes should support these performance requirements
  - Storage must be remote and Kubernetes-compatible

- **For Business Critical tier**:
  - Uses local storage for improved performance
  - Each replica maintains its own copy
  - Storage performance typically higher than General Purpose

- **Kubernetes Storage Considerations**:
  - Log and data volumes should use separate storage classes
  - For backups: Use ReadWriteMany (RWX) capable storage
  - Consider storage latency requirements
  - Storage class should support volume expansion

### Step 6: Data Controller Resource Requirements

- Data controller basic requirements:
  - CPU: 4 cores
  - Memory: 16 GB
  - Storage: Multiple persistent volumes for control components
  - Network: Internal connectivity for components

- Consider if data controller will be shared with other services

### Step 7: Network Requirements and Considerations

- Internal Kubernetes network: 10 Gbps minimum recommended
- External connectivity: Based on client needs
- For HA in Business Critical tier: Consider network bandwidth for replica synchronization
- Network latency: Important for transaction performance

### Step 8: Azure Local Host Requirements

- Total CPU requirements:
  - SQL MI requirements: _____ vCPUs
  - Data Controller requirements: 4 vCPUs
  - Kubernetes system requirements: 2-4 vCPUs
  - Host OS overhead (10-15%): _____ vCPUs
  - Total CPU requirements: _____ vCPUs

- Total memory requirements:
  - SQL MI requirements: _____ GB
  - Data Controller requirements: 16 GB
  - Kubernetes system requirements: 4-8 GB
  - Host OS overhead (10%): _____ GB
  - Total memory requirements: _____ GB

- Total storage requirements:
  - SQL MI data volume: _____ GB
  - SQL MI log volume: _____ GB
  - Data Controller volumes: 20-40 GB
  - Operating system: 100 GB
  - Total storage requirements: _____ GB

### Step 9: Scalability Planning

- Plan for future growth:
  - Additional SQL instances: _____
  - CPU headroom: 20-30%
  - Memory headroom: 20-30%
  - Storage expansion capability: _____

## Capacity Planning Resources

For more detailed calculations, use the [PowerShell Sizing Calculator](../tools/AzureLocalSQLMICalculator.ps1) included in the tools section.

For additional guidance, refer to:
- [Concrete Sizing Methodology](./calculations.md)
- [Understanding Database Workload](./database-workload.md)
