# AKS on Azure Local Networking Best Practices

## Network Architecture

AKS on Azure Local uses Calico CNI in VXLAN mode to provide the network infrastructure for Kubernetes clusters. This creates overlay networks where pod IP addresses are virtualized and tunneled through the physical network infrastructure.

### Networking Model

- **Calico CNI in VXLAN mode**: Each pod is assigned an IP address from the pod network CIDR, but this IP address is not directly routable on the physical network. Instead, it's encapsulated within network packets and sent through the underlying physical network.

- **Networking Speeds**: Use at least 10 Gbps networking for production environments to ensure optimal performance and low latency.
  
- **Network Segmentation**: Implement separate networks for management, VM traffic, and storage to enhance security and performance.

## IP Address Planning

### Default IP Address Ranges

AKS on Azure Local uses the following default IP address ranges:

- **Pod Network CIDR**: `10.244.0.0/16` (Customizable using `--pod-cidr` parameter when creating an AKS cluster)
- **Service Network CIDR**: `10.96.0.0/12` (Not customizable in current version)

### Logical Network (LNET) Considerations

Logical networks on Azure Local are used by both AKS clusters and Arc VMs. You can configure them in one of two ways:

1. **Shared Logical Network**: Share a logical network between AKS and Arc VMs
   - Benefits: Streamlined communication, cost savings, simplified network management
   - Challenges: Resource contention, security risks, more complex troubleshooting

2. **Separate Logical Networks**: Define separate logical networks for AKS clusters and Arc VMs
   - Benefits: Better isolation, simplified troubleshooting, dedicated resources
   - Challenges: More complex communication between services if needed

### IP Address Planning Best Practices

- **Size for Growth**: Ensure your pod CIDR range is large enough to support expected growth
- **Avoid Overlaps**: Verify that pod and service CIDRs don't overlap with existing networks
- **Account for Scaling**: Remember that nodes use IPs from the logical network, and each node needs its own IP address
- **Consider IP Address Density**: Plan for how many pods per node you expect to run

## Load Balancing

AKS on Azure Local uses MetalLB as the load balancer solution:

```azurecli
az k8s-runtime load-balancer create --load-balancer-name $lbName \
  --resource-uri subscriptions/$subscription/resourceGroups/$resource_group/providers/Microsoft.Kubernetes/connectedClusters/metallb-demo \
  --addresses 10.220.32.47-10.220.32.49 --advertise-mode ARP
```

- **IP Address Pool**: Configure MetalLB with an IP pool in the same subnet as the Arc VM logical network
- **Multiple IP Pools**: Add more IP pools if your application needs increase
- **Right-size IP Pools**: Allocate enough IPs for all expected services (minimum 3 recommended)

## Network Policies

Calico Network Policies are supported for AKS on Azure Local and provide a way to control traffic flow between pods.

- **Implement Default Deny**: Start with a default deny policy and explicitly allow required traffic
- **Isolate Namespaces**: Use network policies to isolate different namespaces from each other
- **Limit Egress Traffic**: Control outbound connections from pods to enhance security
- **Label-based Policies**: Use Kubernetes labels to create fine-grained network policies

## Performance Considerations

- **Monitor Network Throughput**: Regularly monitor network performance between nodes
- **Understand VXLAN Overhead**: The overlay network adds a small latency overhead compared to direct networking
- **Optimize Pod Placement**: Consider network proximity when placing pods that communicate frequently
- **Network Bandwidth Planning**: Ensure physical network capacity can handle the combined traffic of all pods

By following these best practices, you can ensure a robust and efficient network configuration for your AKS on Azure Local environment.