# High Availability and Resilience Requirements

## Availability Sets in AKS on Azure Local

Availability sets are logical groups of VMs that have weak anti-affinity relationships with each other, ensuring they are spread evenly across available fault domains (physical hosts) in a cluster. This feature improves the availability and distribution of your Kubernetes workloads in AKS on Azure Local.

### Key Benefits of Availability Sets

- **Improved Workload Resilience**: Prevents scenarios where multiple VMs within the same node pool or control plane fail simultaneously due to a single node failure
- **Automated VM Distribution**: Ensures VMs are evenly distributed across the available nodes rather than concentrated on a single node
- **VM Rebalancing**: When a host recovers from a temporary outage, availability sets help automatically rebalance VMs, returning them to an optimal distribution

### How Availability Sets Work

In AKS on Azure Local, availability sets are **enabled by default** when you create a new AKS Arc cluster. The system automatically creates:
- One availability set for the control plane VMs
- One availability set for each node pool in the Kubernetes cluster

When using this configuration:

1. VMs of the same role (control plane or node pool) are automatically placed on different physical hosts
2. If a physical host fails, affected VMs fail over to other hosts
3. When the failed host recovers, VMs are automatically rebalanced across the available hosts

#### Example Scenario

With a two-host AKS on Azure Local environment (Host A and Host B):

1. **Normal Operation**: Control plane VMs and node pool VMs are distributed across both hosts
2. **Host B Failure**: All VMs on Host B fail over to Host A
3. **Host B Recovery**: The availability set ensures VMs are automatically rebalanced back to Host B

### Physical Host Changes and Availability Sets

- **Host Deletion**: If a physical machine is permanently removed from the cluster, the availability set enters an unhealthy state. It's recommended to redeploy your Kubernetes clusters to update the availability set with the proper number of fault domains.

- **Host Addition**: When a new physical machine is added to the cluster, the availability set configuration automatically expands, but existing VMs don't automatically rebalance. Consider redeploying your clusters to ensure optimal distribution.

## High Availability Planning

When planning for high availability in AKS on Azure Local, consider these key questions:

- **What is the required uptime and Service Level Objective (SLO) for the application?**
  
- **How much physical node failure can the Azure Local cluster tolerate while maintaining the required resources for the Kubernetes cluster and application pods?**
  - This relates to the number of Azure Local nodes and their configuration (e.g., 2-node, 3-node, or more).
  - For production workloads, a minimum of 3 physical nodes is recommended.

- **How will planned maintenance on the Azure Local nodes be handled?**
  - Do you have enough overhead to evacuate and patch nodes without downtime for your Kubernetes applications?
  - Plan for N+1 capacity to accommodate maintenance operations.

- **How does the storage fault tolerance in Storage Spaces Direct (e.g., two-way mirror, three-way mirror) align with your application's data availability requirements?**
  - Two-way mirrors require at least 2 physical nodes
  - Three-way mirrors require at least 3 physical nodes but provide higher resilience

## Control Plane Availability

For high availability of the Kubernetes control plane:

- Deploy 3 or 5 control plane nodes (odd numbers recommended for quorum)
- Ensure control plane nodes are distributed across multiple physical hosts using availability sets
- Plan for sufficient resources to maintain control plane operations even if a physical node fails

## Worker Node Availability

- For production environments, deploy at least 3 worker nodes
- Use multiple node pools to isolate workloads with different availability requirements
- Leverage pod disruption budgets to ensure application availability during node maintenance