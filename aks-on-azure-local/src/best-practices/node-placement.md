# Node Placement Strategies for AKS on Azure Local

## Availability Sets in AKS on Azure Local

Availability sets are a key feature in AKS on Azure Local that improves the availability and resilience of your applications. They are logical groups of VMs that have weak anti-affinity relationships with each other, ensuring they are spread evenly across available fault domains (physical hosts) in a cluster.

### Benefits of Availability Sets

- **Improved Availability**: Prevents scenarios where multiple VMs within the same node pool or control plane fail due to a single node failure
- **Optimized Resource Usage**: Ensures VMs are evenly distributed across available nodes rather than concentrated on a single node
- **Aligned with Best Practices**: Provides a reliable and consistent on-premises Kubernetes experience

### How Availability Sets Work

When creating a new AKS Arc cluster, availability sets are automatically created:
- One for the control plane VMs
- One for each node pool in the Kubernetes cluster

This ensures VMs of the same role are never located on the same physical host and are properly distributed across available nodes.

## Node Placement Best Practices

- **Leverage Availability Sets**: AKS on Azure Local enables availability sets by default, ensuring proper VM distribution across physical hosts.

- **Distribute Control Plane Nodes**: For high availability, use 3 or 5 control plane nodes distributed across multiple physical hosts.

- **Mixed OS Deployments**: For clusters with both Linux and Windows worker nodes:
  - Use **Node Selector** in pod specs to constrain pods to specific OS nodes
  - Implement **Taints and Tolerations** to ensure pods aren't scheduled onto inappropriate nodes
  - Always maintain at least one Linux node pool to host the Arc agents for Azure connectivity

- **Specialized Workload Taints and Tolerations**: Configure taints and tolerations for specialized workloads, such as those requiring GPU or high memory. This allows you to control which nodes can run specific workloads, optimizing resource utilization.

- **Node Pools for Workload Types**: Consider creating dedicated node pools for different types of workloads. AKS on Azure Local supports up to 16 node pools per cluster with up to 64 nodes per node pool.

- **GPU Workloads**: For GPU workloads, use the appropriate VM sizes that support your GPU models:
  - Nvidia T4 (supported by NK T4 SKUs)
  - Nvidia A2 (supported by NC2 A2 SKUs)
  - Nvidia A16 (supported by NC2 A16 SKUs)

- **Resource Requests and Limits**: Set appropriate resource requests and limits for pods to ensure that the Kubernetes scheduler can make informed decisions about pod placement.

- **Autoscaling**: Consider enabling the cluster autoscaler for dynamic scaling of node count based on workload demands. Be aware that autoscaling has different scale limits:
  - Maximum of 12 clusters with autoscaler enabled
  - 4 concurrent cluster or node pool creations

- **Monitoring and Adjustments**: Continuously monitor node performance and workload distribution. Be prepared to adjust node placements and configurations based on observed metrics.

By following these node placement strategies and understanding the specific capabilities of AKS on Azure Local, you can enhance the reliability, performance, and efficiency of your Kubernetes deployments.