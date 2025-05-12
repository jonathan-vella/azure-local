# Concrete Sizing Methodology for AKS on Azure Local

This document provides detailed guidance on sizing AKS clusters on Azure Local, including VM size selection, scaling calculations, and resource planning.

## Virtual Machine Size Calculations

### Default VM Sizes for AKS on Azure Local

AKS on Azure Local uses the following default VM sizes:

| Component | Default VM Size | Specifications |
|-----------|----------------|----------------|
| AKS Arc control plane nodes | Standard_A4_v2 | 4 vCPUs, 8 GB RAM |
| AKS Arc Linux worker node | Standard_A4_v2 | 4 vCPUs, 8 GB RAM |
| AKS Arc Windows worker node | Standard_K8S3_v1 | 4 vCPUs, 6 GB RAM |

### Supported VM Sizes for Control Plane Nodes

You can customize the control plane node size from these supported options:

| VM Size | vCPUs | Memory (GB) |
|---------|-------|-------------|
| Standard_K8S3_v1 | 4 | 6 |
| Standard_A4_v2 | 4 | 8 |
| Standard_D4s_v3 | 4 | 16 |
| Standard_D8s_v3 | 8 | 32 |

### Supported VM Sizes for Worker Nodes

Worker nodes can use these VM sizes:

| VM Size | vCPUs | Memory (GB) |
|---------|-------|-------------|
| Standard_A2_v2 | 2 | 4 |
| Standard_K8S3_v1 | 4 | 6 |
| Standard_A4_v2 | 4 | 8 |
| Standard_D4s_v3 | 4 | 16 |
| Standard_D8s_v3 | 8 | 32 |
| Standard_D16s_v3 | 16 | 64 |
| Standard_D32s_v3 | 32 | 128 |

### GPU-Enabled VM Sizes

For workloads requiring GPU acceleration, the following sizes are available:

#### Nvidia T4 (NK T4 SKUs)
| VM Size | GPUs | Memory (GB) | vCPUs | Temp Storage (GB) |
|---------|------|-------------|-------|-------------------|
| Standard_NK6 | 1 | 56 | 6 | 340 |
| Standard_NK12 | 2 | 112 | 12 | 680 |

#### Nvidia A2 (NC2 A2 SKUs)
| VM Size | GPUs | Memory (GB) | vCPUs | Temp Storage (GB) |
|---------|------|-------------|-------|-------------------|
| Standard_NC4_A2 | 1 | 16 | 4 | 150 |
| Standard_NC8_A2 | 1 | 16 | 8 | 300 |
| Standard_NC16_A2 | 2 | 32 | 16 | 600 |
| Standard_NC32_A2 | 2 | 32 | 32 | 1200 |

#### Nvidia A16 (NC2 A16 SKUs)
| VM Size | GPUs | Memory (GB) | vCPUs | Temp Storage (GB) |
|---------|------|-------------|-------|-------------------|
| Standard_NC4_A16 | 1 | 16 | 4 | 150 |
| Standard_NC8_A16 | 1 | 16 | 8 | 300 |
| Standard_NC16_A16 | 2 | 32 | 16 | 600 |
| Standard_NC32_A16 | 2 | 32 | 32 | 1200 |

## Resource Planning Formulas

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