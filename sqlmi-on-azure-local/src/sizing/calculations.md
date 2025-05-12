# Concrete Sizing Methodology

## Azure Arc Data Controller Sizing

The data controller is a collection of pods that are deployed to your Kubernetes cluster to provide an API, controller service, bootstrapper, and monitoring databases and dashboards. This is the baseline for your SQL Managed Instance deployment.

| Component | CPU Request | Memory Request | CPU Limit | Memory Limit |
|-----------|------------|---------------|-----------|--------------|
| bootstrapper | 100m | 100Mi | 200m | 200Mi |
| control | 400m | 2Gi | 1800m | 2Gi |
| controldb | 200m | 4Gi | 800m | 6Gi |
| logsdb | 200m | 1600Mi | 2 | 1600Mi |
| logsui | 100m | 500Mi | 2 | 2Gi |
| metricsdb | 200m | 800Mi | 400m | 2Gi |
| metricsdc | 100m | 200Mi | 200m | 300Mi |
| metricsui | 20m | 200Mi | 500m | 200Mi |

The baseline size for the data controller requires approximately **4 cores** and **16GB RAM**.

## SQL Managed Instance Sizing Requirements

Each SQL Managed Instance must have the following minimum resource requests and limits:

| Resource | General Purpose | Business Critical |
|----------|----------------|-------------------|
| CPU request | Minimum: 1, Maximum: 24, Default: 2 | Minimum: 3, Maximum: unlimited, Default: 4 |
| CPU limit | Minimum: 1, Maximum: 24, Default: 2 | Minimum: 3, Maximum: unlimited, Default: 4 |
| Memory request | Minimum: 2Gi, Maximum: 128Gi, Default: 4Gi | Minimum: 2Gi, Maximum: unlimited, Default: 4Gi |
| Memory limit | Minimum: 2Gi, Maximum: 128Gi, Default: 4Gi | Minimum: 2Gi, Maximum: unlimited, Default: 4Gi |

### SQL Managed Instance Container Components

Each SQL Managed Instance pod that is created has three containers:

| Container | CPU Request | Memory Request | CPU Limit | Memory Limit | Notes |
|-----------|------------|---------------|-----------|--------------|-------|
| fluentbit | 100m | 100Mi | Not specified | Not specified | The fluentbit container resource requests are in addition to the requests specified for the SQL managed instance |
| arc-sqlmi | User specified or not specified | User specified or not specified | User specified or not specified | User specified or not specified | Main SQL MI container |
| collectd | Not specified | Not specified | Not specified | Not specified | Metrics collection container |

## Storage Sizing Considerations

### Storage Class Selection
For SQL Managed Instances, consider the following factors when choosing a storage class:
- **Performance needs**: Database performance is largely a function of I/O throughput
- **High availability**: For single pod instances, use remote, shared storage to ensure data durability
- **Storage separation**: Separate data, logs, and backups onto different storage classes for better performance

### Storage Volume Requirements

Each SQL Managed Instance requires storage for:

1. **Data Files**:
   - Path: `/var/opt` - Contains directories for the mssql installation and data
   - Default size: 5Gi (should be sized based on your database requirements)
   - Performance: Requires high IOPS for OLTP workloads

2. **Log Files**:
   - Path: `/var/log` - Contains console output and other logging information
   - Default size: 5Gi
   - Performance: Transaction log files require sequential write performance

3. **Backup Storage**:
   - Requires ReadWriteMany (RWX) capable storage class
   - Used for database backups and point-in-time recovery

## High Availability Considerations

For Business Critical tier SQL Managed Instances:
- Uses Always On Availability Groups to replicate data between instances
- Synchronous replication maintains multiple copies of data (typically three copies)
- Can use either local storage or remote shared storage classes for data and log files
- May provide better performance with local storage due to multiple data copies

## Total Resource Calculation Formula

When calculating the total resources required for your SQL Managed Instance on Azure Local deployment:

1. **Total Data Controller Resources**:
   - 4 cores and 16GB RAM baseline

2. **Total SQL MI Resources**:
   - Sum of all SQL MI instances and their agent containers
   - For each instance: Instance resources + Agent resources (250m CPU, 250Mi RAM)

3. **Physical Host Requirements**:
   - Add at least 25% capacity buffer for Kubernetes scheduling
   - Account for host OS overhead (10% of physical cores, 4-8GB per host)
   - Account for Azure Local management (2-4 cores, 8-16GB per host)
   - Account for hypervisor overhead (5% of VM allocation)

## Estimating Storage Requirements

Each pod that contains stateful data uses at least two persistent volumes - one for data and another for logs. For a sample deployment:

| Component | Number of Instances | Persistent Volumes per Instance | Total Persistent Volumes |
|-----------|--------------------|-----------------------------|------------------------|
| Data Controller | 1 | 8 (control, controldb, logsdb, metricsdb × 2 each) | 8 |
| SQL Managed Instance | 1 | 2 (data and logs) | 2 |
| SQL MI with High Availability | 1 | 6 (data and logs × 3 replicas) | 6 |

### Sizing Recommendations for Common Workloads

| Workload Type | vCPU | Memory | Storage Requirements |
|---------------|------|--------|---------------------|
| Small OLTP | 2-4 | 8-16 GB | Data: 50GB+, Logs: 25GB+ |
| Medium OLTP | 4-8 | 16-32 GB | Data: 200GB+, Logs: 50GB+ |
| Large OLTP | 8-24 | 32-128 GB | Data: 500GB+, Logs: 100GB+ |
| Data Warehouse | 8-24 | 32-128 GB | Data: 1TB+, Logs: 100GB+ |

### Azure Local Resource Reservation Guidelines

| Component | CPU Reservation | Memory Reservation | Notes |
|-----------|----------------|-------------------|-------|
| Host OS (Windows Server) | 10% of physical cores | 4-8 GB per host | Higher for hosts with 256GB+ RAM |
| Azure Local management | 2-4 cores per host | 8-16 GB per host | Includes clustering, storage, etc. |
| Kubernetes system | 1-2 cores | 2-4 GB | Kubernetes components |
| SQL MI containers | As calculated | As calculated | Based on workload requirements |

**Note**: Always allocate at least 2 physical cores and 8GB RAM for the host OS and related services regardless of instance size.

## Network Considerations

For Azure Arc data services on Azure Local:

- **Internal Network**: 10 Gbps minimum network connectivity between hosts and storage
- **Plan for redundant network paths** for high availability
- **Network bandwidth** for synchronization between availability replicas in Business Critical tier
- **Client connections** based on expected workload and number of concurrent users

## Kubernetes Storage Considerations

When deploying SQL MI on Azure Local, consider these Kubernetes storage aspects:

- **Storage Classes**: Choose appropriate storage classes for data, logs, and backups
- **Storage Performance**: Match storage performance to workload requirements
- **Access Modes**: Use ReadWriteOnce (RWO) for data and logs, ReadWriteMany (RWX) for backups
- **Persistent Volume Claims**: Each SQL MI creates separate PVCs for data and logs

   - **Recommended Minimum**:
     - Small instances: 1 Gbps dedicated
     - Medium/large instances: 10 Gbps dedicated
     - Multi-instance deployments: 10+ Gbps with QoS

## TempDB Configuration

1. **File Count**:
   - One file per physical CPU core, up to 8 files
   - Equal size for all files
   - Example: 16 core VM = 8 TempDB data files

2. **Initial Size**:
   - Minimum: 8 GB per file for typical workloads
   - For heavy ETL/OLAP: 16+ GB per file
   - Preallocate to full size to avoid autogrowth events
