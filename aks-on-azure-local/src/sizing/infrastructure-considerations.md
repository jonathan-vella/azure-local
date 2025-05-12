# Azure Local and Physical Infrastructure Considerations for AKS

## AKS on Azure Local Architecture

AKS on Azure Local uses Arc Resource Bridge (also known as Arc appliance) to provide the core orchestration mechanism and interface for deploying and managing one or more AKS clusters. The architecture consists of the following key components:

### Arc Resource Bridge
The Arc Resource Bridge connects Azure Local to Azure and enables on-premises resource management from Azure. It includes:
- **AKS Arc cluster extensions**: On-premises equivalent of an Azure Resource Manager resource provider
- **Custom location**: On-premises equivalent of an Azure region, extending the Azure location construct

### AKS Clusters
AKS clusters are high availability deployments of Kubernetes with:
- **Control Plane Nodes**: Manage the Kubernetes cluster and run components such as the API server and etcd
- **Linux/Windows Node Pools**: Groups of nodes that share the same configuration, with at least one Linux node pool required to host the Arc agents

## Scale Requirements for AKS on Azure Local

When planning your AKS deployment on Azure Local, consider the following scale requirements:

| Resource | Minimum | Maximum |
|----------|---------|---------|
| Number of physical nodes in an Azure Local cluster | 1 | 16 |
| Count of control plane nodes (Allowed values are 1, 3, and 5) | 1 | 5 |
| Number of nodes in default node pool created during cluster create | 1 | 200 |
| Number of node pools in an AKS cluster | 1 | 16 |
| Number of nodes in a node pool (empty node pools not supported) | 1 | 64 |
| Total number of nodes in an AKS cluster across node pools | 1 | 200 |
| Number of AKS clusters per Azure Local cluster | 0 | 32 |

### Considerations When Using Autoscaler

When using the autoscaler feature, be aware of the following additional limitations:
- Maximum number of AKS clusters with autoscaler enabled: 12
- Number of concurrent AKS cluster creations: 4
- Number of concurrent node pool creations: 4

## Virtual Machine Sizing Considerations

### Default VM Sizes
| Component | Default Size | Specifications |
|-----------|--------------|----------------|
| AKS Arc control plane nodes | Standard_A4_v2 | 8-GB memory, 4 vCPU |
| AKS Arc Linux worker node | Standard_A4_v2 | 8-GB memory, 4 vCPU |
| AKS Arc Windows worker node | Standard_K8S3_v1 | 6-GB memory, 4 vCPU |

### IP Address Planning

Proper IP address planning is essential for AKS on Azure Local deployments. You need to allocate IP addresses for:

- AKS Arc node VMs (one IP per Kubernetes node)
- Kubernetes version upgrade operations (one IP per AKS Arc cluster)
- Control plane IPs (one IP per AKS cluster)
- Load balancer IPs (varies based on application needs)

Additionally, plan your Pod CIDR (default 10.244.0.0/16) and Service CIDR (default 10.96.0.0/12) for internal Kubernetes networking.

## Performance Considerations

- What are the storage configurations on Azure Local (Storage Spaces Direct setup, drive types)?
  - This directly impacts the performance and capacity of Persistent Volumes used by your applications.
  
- What is the percentage overhead of the Azure Local operating system and other management components running on the physical nodes?
  - These resources are consumed before any resources are available for Kubernetes VMs.
  
- What are the target CPU and memory utilization per node (60–75%)?
  
- Are there latency or throughput SLAs to meet?