# Storage Configuration Best Practices for Azure Arc SQL MI

This document outlines the best practices for configuring storage for Azure Arc-enabled SQL Managed Instance deployments in Azure Local environments.

## Storage Classes for SQL Managed Instance

When deploying SQL Managed Instance on Azure Local, the selection of appropriate storage classes is critical for ensuring optimal performance and reliability.

### General Storage Recommendations

1. **Use separate storage classes** for different types of storage:
   - Data volume storage (`/var/opt/mssql`) - Requires high performance
   - Log volume storage (`/var/log/mssql`) - Requires low latency for transaction log performance
   - Backup storage - Requires high capacity and ReadWriteMany (RWX) access mode

2. **Storage performance tiers**:
   - Premium storage for production workloads
   - Standard storage for development/testing environments

3. **When using local storage**:
   - Enable backup and disaster recovery solutions
   - Consider redundancy options at the storage layer

### Storage Class Selection by Service Tier

#### General Purpose

For General Purpose tier SQL Managed Instances:

- Uses remote storage volumes that are attached to SQL pods
- Requires Kubernetes storage classes that support:
  - ReadWriteOnce (RWO) access mode
  - Dynamic volume provisioning
  - Volume expansion (for growing databases)
  - Sufficient performance for database workloads

#### Business Critical

For Business Critical tier SQL Managed Instances:

- Uses local storage for improved performance
- Data replication is handled by Always On Availability Groups
- Typically provides better performance than General Purpose tier
- Each replica maintains its own copy of the data

## Best Practices for Performance

1. **Storage Performance Planning**:
   - Provision adequate IOPS for database workloads
   - Consider throughput requirements for backup/restore operations
   - Monitor storage latency and adjust as needed

2. **Storage Latency Requirements**:
   - Data files: < 10 ms average latency
   - Log files: < 5 ms average latency (critical for transaction performance)
   - Consider SSD-based storage for optimal performance

3. **Backup Storage Considerations**:
   - Use separate storage for database backups
   - Ensure backup storage class supports ReadWriteMany (RWX) access mode
   - Size backup storage based on retention policies and database size

## Kubernetes Storage Configurations

### Storage Class Parameters

Configure Kubernetes storage classes with appropriate parameters:

```yaml
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: sqlmi-premium-storage
provisioner: kubernetes.io/azure-disk
parameters:
  storageaccounttype: Premium_LRS
  kind: Managed
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
```

### Persistent Volume Claims

Each SQL Managed Instance requires persistent volume claims for data and logs:

```yaml
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: data-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 100Gi
  storageClassName: sqlmi-premium-storage
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: logs-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 25Gi
  storageClassName: sqlmi-premium-storage
```

## Storage Management and Monitoring

1. **Regular monitoring** of storage usage and performance:
   - Monitor free space on persistent volumes
   - Track IOPS and latency metrics
   - Set up alerts for storage capacity thresholds

2. **Volume expansion strategy**:
   - Use storage classes that support online volume expansion
   - Plan for periodic volume expansion based on growth rates
   - Monitor volume expansion operations

3. **Performance optimization**:
   - Regularly defragment database files
   - Monitor and adjust file autogrowth settings
   - Consider data compression for large tables

## Data Protection Strategies

1. **Backup and Restore**:
   - Implement regular database backups
   - Use Azure Blob Storage as a backup target when possible
   - Test restore procedures regularly

2. **High Availability**:
   - For General Purpose: Rely on storage redundancy
   - For Business Critical: Leverage Always On Availability Groups

3. **Disaster Recovery**:
   - Implement cross-region backup strategies
   - Consider Azure Site Recovery for host protection

## Implementation Checklist

- [ ] Define storage performance requirements based on workload
- [ ] Create appropriate storage classes in Kubernetes
- [ ] Configure persistent volume claims for SQL MI data and logs
- [ ] Set up backup storage with appropriate access mode
- [ ] Implement monitoring for storage performance and capacity
- [ ] Test backup and restore procedures
- [ ] Document storage configuration for operational reference
