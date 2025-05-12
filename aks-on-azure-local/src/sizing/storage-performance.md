# Storage Performance Recommendations for Workload Types

## Workload Type Recommendations

| Workload Type | Recommended Storage | Min IOPS | Network Requirements |
|---------------|---------------------|----------|---------------------|
| Database      | Premium SSD or NVMe | 5000+    | Low latency (<2ms)  |
| Web/API       | Standard SSD        | 1000+    | Standard            |
| Batch Processing | Standard SSD with caching | 2000+ | High throughput     |
| Log Collection | Standard HDD with caching | 500+  | High throughput      |

## Storage Spaces Direct Configuration Recommendations

- **Cache tier**: NVMe or SSD (20-25% of total capacity)
- **Capacity tier**: SSD or HDD based on workload IOPS requirements
- **Physical disk ratio**: Minimum 4 physical disks per node for redundancy
- **Performance testing**: Use FIO or DiskSpd to validate before production deployment