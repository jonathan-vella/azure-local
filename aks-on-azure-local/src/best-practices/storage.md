# Storage Configuration Best Practices for AKS on Azure Local

## Storage Options in AKS on Azure Local

AKS on Azure Local provides several storage options for containerized applications through Container Storage Interface (CSI) drivers:

### Container Storage Interface (CSI) Support

CSI is the standard for exposing block and file storage systems to containerized workloads on Kubernetes. AKS on Azure Local implements CSI-compliant drivers that enable:

1. **CSI Disk Drivers**: 
   - Create Kubernetes DataDisk resources
   - Mounted as ReadWriteOnce (available to a single pod at a time)
   - VHDX-backed volumes with dynamic provisioning

2. **CSI File Drivers**: 
   - Mount SMB or NFS shares to pods
   - Supports ReadWriteMany access mode (can be shared across multiple nodes and pods)
   - Ideal for scenarios requiring concurrent access by multiple pods

## Storage Classes

AKS on Azure Local provides built-in storage classes for dynamic storage provisioning:

- The **default** storage class is automatically created and uses CSI to provision VHDX-backed volumes
- Persistent volumes created with this storage class are expandable by editing the PVC with a new size
- The reclaim policy ensures underlying VHDX is deleted when the persistent volume is deleted

### Custom Storage Classes

You can create custom storage classes to define specific storage characteristics:

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: custom-storage
provisioner: disk.csi.akshci.com
parameters:
  # Custom parameters as needed
reclaimPolicy: Delete
allowVolumeExpansion: true
```

## Storage Types and Performance Considerations

- **Premium SSD or NVMe**: Recommended for production environments, especially for workloads requiring high IOPS and low latency.
- **Standard SSD**: Suitable for general-purpose workloads with moderate performance requirements.
- **Standard HDD**: Can be used for less critical workloads where performance is not a primary concern.

## Mirroring Strategies for Underlying Storage

- **3-Way Mirroring**: Essential for critical data to ensure high availability and fault tolerance. This configuration provides redundancy and protects against data loss.
- **2-Way Mirroring**: Can be used for less critical data where some level of redundancy is acceptable, but it does not provide the same level of fault tolerance as 3-way mirroring.

## Storage Pool Sizing

- Always size storage pools with at least **30% additional capacity** to accommodate snapshots, growth, and unexpected increases in demand.
- Regularly monitor storage utilization to ensure that capacity planning aligns with actual usage patterns.

## Multi-Pod Access Considerations

When multiple pods need access to the same storage:

- Use CSI File drivers (SMB or NFS) with ReadWriteMany access mode
- For SMB support, use the built-in SMB CSI driver
- For NFS support, use the built-in NFS CSI driver

Example NFS storage class:

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: nfs-csi
provisioner: nfs.csi.akshci.com
parameters:
  server: nfs-server.default.svc.cluster.local
  share: /
reclaimPolicy: Retain
volumeBindingMode: Immediate
mountOptions:
  - hard
  - nfsvers=4.1
```

## Performance Testing

- Conduct performance testing using tools like **FIO** or **DiskSpd** to validate storage performance before deploying workloads to production.
- Test different configurations to determine the optimal setup for your specific workload requirements.
- Monitor storage performance metrics through Azure Arc integration.

## Backup and Recovery

- Implement a robust backup strategy that includes regular snapshots and offsite backups to protect against data loss.
- Ensure that recovery procedures are tested and documented to minimize downtime in case of failures.
- Consider integrating with Azure Backup services for comprehensive protection.

## Best Practices

1. **Use persistent volumes for stateful applications**: Ensures data persists across pod lifecycle events
2. **Properly size your PVCs**: Request appropriate storage capacity based on workload needs
3. **Use the appropriate access mode**: ReadWriteOnce for single-pod access, ReadWriteMany for multi-pod access
4. **Monitor storage utilization**: Track usage to prevent capacity-related issues
5. **Consider storage performance requirements**: Match storage class to workload IO needs

By following these best practices, you can optimize storage configurations for your AKS on Azure Local environment, ensuring high performance, availability, and reliability for your applications.