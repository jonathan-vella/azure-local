# SQL MI Instance Configuration Best Practices

This document outlines the best practices for configuring Azure Arc-enabled SQL Managed Instance deployments in Azure Local environments.

## Instance Configuration Guidelines

### Service Tier Selection

Choose the appropriate service tier based on your workload requirements:

1. **General Purpose Tier**
   - Best for most business workloads
   - Cost-effective solution for development, testing, and standard production workloads
   - Uses remote storage with Kubernetes storage classes
   - Appropriate when:
     - Budget constraints are a primary concern
     - You have moderate performance requirements
     - Your workload can tolerate typical network latencies
     - You're running non-mission-critical applications

2. **Business Critical Tier**
   - Best for mission-critical workloads requiring high performance
   - Uses local storage for lower latency and higher IOPS
   - Includes built-in high availability with Always On Availability Groups
   - Appropriate when:
     - You need the highest performance and lowest latency
     - Mission-critical applications require high availability
     - You require ReadyReplicas for read workload scaling
     - Performance is prioritized over cost considerations

## Resource Configuration

### CPU Configuration

1. **Right-sizing vCores**:
   - Start with the minimum required for your workload type
   - General Purpose: 1-24 vCores available
   - Business Critical: Minimum 3 vCores, no upper limit
   - Consider peak workload periods in sizing decisions

2. **CPU Limits and Requests**:
   - Always set CPU requests equal to limits for predictable performance
   - Avoid over-committing CPU resources in the Kubernetes cluster
   - Monitor CPU utilization and adjust as needed

### Memory Configuration

1. **Buffer Pool Sizing**:
   - Target buffer pool size: 70-80% of total database size for optimal performance
   - Account for additional SQL Server operational memory (2-4GB)
   - Set memory limits and requests to identical values

2. **Memory Management Best Practices**:
   - Configure max server memory setting appropriately
   - Allow sufficient memory for operating system functions
   - Monitor memory pressure indicators

### Storage Configuration

1. **Volume Configuration**:
   - Separate volumes for data and log files
   - Provision sufficient storage for projected growth
   - Use high-performance storage for transaction logs

2. **TempDB Configuration**:
   - Create multiple TempDB files (typically 4-8)
   - Size TempDB appropriately for workload (25-30% of largest user database)
   - Monitor TempDB usage and adjust as needed

## SQL Server Configuration Options

### Database Configuration

1. **Recovery Model**:
   - Use Full recovery model for production databases
   - Consider Simple recovery model only for non-critical environments
   - Implement proper transaction log backup strategy for Full recovery model

2. **Auto-growth Settings**:
   - Configure fixed-size auto-growth increments (not percentage-based)
   - Data files: 100MB-1GB growth increments based on database size
   - Log files: 64MB-1GB growth increments based on transaction volume
   - Consider pre-growing files to expected size

3. **MAXDOP Configuration**:
   - Configure based on available vCores
   - General recommendation: MAXDOP = number of vCores up to 8
   - For larger instances, consider limiting MAXDOP to 8

### Performance Configuration

1. **Instance-Level Settings**:
   ```sql
   -- Configure optimal settings
   EXEC sp_configure 'show advanced options', 1;
   RECONFIGURE WITH OVERRIDE;
   EXEC sp_configure 'max degree of parallelism', 4;
   EXEC sp_configure 'cost threshold for parallelism', 50;
   EXEC sp_configure 'optimize for ad hoc workloads', 1;
   RECONFIGURE WITH OVERRIDE;
   ```

2. **Resource Governor** (available in Business Critical tier):
   - Implement to manage resource utilization
   - Create workload groups for different application types
   - Limit CPU and memory usage for specific workloads

## High Availability Configuration

### Business Critical Tier HA

1. **ReadyReplica Configuration**:
   - Configure secondary replicas for read workloads
   - Set appropriate read-only routing to distribute read workloads
   - Monitor replica synchronization health

2. **Failover Configuration**:
   - Test failover scenarios regularly
   - Implement proper connection retry logic in applications
   - Document failover procedures for operations teams

### Backup and Restore Strategy

1. **Backup Configuration**:
   - Implement regular full, differential, and transaction log backups
   - Store backups in a separate storage location
   - Validate backups through regular restore testing

2. **Backup Storage**:
   - Use a storage class with ReadWriteMany (RWX) capability for backups
   - Ensure sufficient capacity for retention period
   - Consider compression for backup storage efficiency

## Monitoring and Maintenance

1. **Monitoring Configuration**:
   - Configure Azure Monitor integration
   - Set up SQL Server Agent jobs for regular maintenance
   - Implement alerting for critical thresholds

2. **Maintenance Jobs**:
   - Index maintenance (rebuild/reorganize)
   - Statistics updates
   - Database integrity checks
   - Log and data file management

## Security Configuration

1. **Authentication**:
   - Use Azure Active Directory authentication when possible
   - Implement proper login security and password policies
   - Limit SQL authentication use to service accounts only

2. **Authorization**:
   - Implement principle of least privilege
   - Use role-based access control
   - Regularly audit permissions

3. **Data Protection**:
   - Enable Transparent Data Encryption (TDE)
   - Implement column-level encryption for sensitive data
   - Configure SQL Audit for compliance requirements

## Operational Management

1. **Configuration Management**:
   - Document all configuration settings
   - Use Azure Policy to enforce configurations
   - Implement change management procedures

2. **Instance Updates**:
   - Plan and test version updates
   - Implement update strategy with minimal downtime
   - Document rollback procedures

## Implementation Checklist

- [ ] Select appropriate service tier based on workload
- [ ] Configure CPU and memory resources correctly
- [ ] Set up proper storage volumes and classes
- [ ] Configure SQL Server instance settings
- [ ] Implement high availability configuration
- [ ] Set up backup and restore strategy
- [ ] Configure monitoring and maintenance
- [ ] Implement security best practices
- [ ] Document configuration and operational procedures
