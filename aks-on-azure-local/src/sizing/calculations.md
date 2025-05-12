# Contents of /azure-local-kubernetes-docs/azure-local-kubernetes-docs/src/sizing/calculations.md

## Concrete Sizing Methodology

### Physical Node Calculation Formula

1. **Base resource calculation**:
   - Total pod CPU requests × (1 + overhead factor) = Required CPU
   - Total pod memory requests × (1 + overhead factor) = Required Memory
   - Overhead factor typically ranges from 0.2-0.3 (20-30%)
   - **Example**: 20 pods with 0.5 CPU each = 10 CPU × 1.25 = 12.5 CPU cores needed

2. **High availability adjustment**:
   - Required resources × (N+1)/N = HA-adjusted resources
   - Where N = minimum number of nodes needed for your workload
   - **Example**: 12.5 CPU with 3-node minimum = 12.5 × (3+1)/3 = 16.7 CPU cores total

3. **Resource overhead per node**:
   - Control plane nodes: Reserve 1-2 vCPUs and 2-4GB RAM for system components
   - Worker nodes: Reserve 0.5-1 vCPU and 1-2GB RAM for system components 
   - Add 10% overhead for Azure Arc management components
   - Azure Local host OS: ~10% of host resources (Windows Server)
   - Virtual machine overhead: ~5% additional for hypervisor

4. **Node density considerations**:
   - Target 60-75% resource utilization for CPU/memory to allow for spikes
   - Calculate: Total required resources ÷ (target utilization × resources per node) = Number of nodes
   - **Example**: 16.7 CPU ÷ (0.7 × 8 CPU per node) = 3 nodes minimum

### Minimum Recommended Node Specifications

| Cluster Size | Control Plane Nodes | Worker Nodes | Min CPU/Node | Min RAM/Node | Storage |
|--------------|---------------------|--------------|--------------|---------------|---------|
| Small (<10 workload pods) | 1 | 2 | 4 cores | 16 GB | 128 GB OS, 256+ GB data |
| Medium (10-50 pods) | 3 | 3+ | 8 cores | 32 GB | 128 GB OS, 512+ GB data |
| Large (50+ pods) | 3 | 5+ | 16+ cores | 64+ GB | 256 GB OS, 1TB+ data |

### Azure Local Resource Reservation Guidelines

| Component | CPU Reservation | Memory Reservation | Notes |
|-----------|----------------|-------------------|-------|
| Host OS (Windows Server) | 10% of physical cores | 4-8 GB per host | Higher for hosts with 256GB+ RAM |
| Azure Local management | 2-4 cores per host | 8-16 GB per host | Includes clustering, storage, etc. |
| Virtual Machine Overhead | 5% of VM allocation | 5% of VM allocation | Hypervisor overhead |
| Control Plane VMs | 2 cores per VM | 4 GB per VM | Minimum for reliable operation |
| Azure Arc Agent | 0.5 core per node | 1 GB per node | For monitoring and management |
| Container Runtime | 0.1 core per pod | 0.1 GB per pod | Scales with pod count |

**Note**: Always allocate at least 2 physical cores and 8GB RAM for the host OS and related services regardless of cluster size.