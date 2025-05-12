# Sizing Examples for Kubernetes on Azure Local

## Example 1: Small Business Web Application
- **Workload**: 1 database, 2 application servers, 1 frontend
- **Traffic**: ~100 concurrent users
- **Resource Requirements**: 8 vCPU, 32GB RAM total
- **Recommended Configuration**: 
  - 3 physical nodes (16 cores, 64GB RAM each)
  - 2-way mirror Storage Spaces Direct
  - 1 Kubernetes control plane, 2 worker nodes

## Example 2: Medium Enterprise Application Suite
- **Workload**: 20+ microservices, 3 databases, message queue
- **Traffic**: ~1000 concurrent users
- **Resource Requirements**: 48 vCPU, 196GB RAM total
- **Recommended Configuration**:
  - 4 physical nodes (24+ cores, 256GB RAM each)
  - 3-way mirror Storage Spaces Direct
  - 3 Kubernetes control planes, 6+ worker nodes

## Example 3: Large Enterprise Microservices Platform
- **Workload**: 60+ microservices, 10+ databases, multiple message queues, batch processors
- **Traffic**: ~10,000+ concurrent users, heavy data processing
- **Resource Requirements**: 200 vCPU, 768GB RAM total
- **Recommended Configuration**:
  - 6-8 physical nodes (32+ cores, 512GB RAM each)
  - 3-way mirror Storage Spaces Direct with all-flash tier
  - 3 Kubernetes control planes, 12+ worker nodes
  - Dedicated physical nodes for storage-intensive workloads
  - Consider separating application tiers across different node pools