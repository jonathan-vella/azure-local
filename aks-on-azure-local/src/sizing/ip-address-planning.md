# IP Address Planning for AKS on Azure Local

Proper IP address planning is essential for successful AKS deployments on Azure Local. This document provides guidance on IP address requirements and strategies for allocation.

## IP Address Requirements

When planning your AKS deployment, you need to consider IP address requirements for various components:

### AKS Node VMs and Infrastructure

| Component | IP Addresses Required | Notes |
|-----------|----------------------|-------|
| AKS Arc VM IPs | 1 per worker node | Reserve through IP pools in the Arc VM logical network |
| AKS Arc K8s version upgrade IPs | 1 per AKS Arc cluster | For Kubernetes version upgrade operations |
| Control plane IP | 1 per Kubernetes cluster | Single IP for accessing the Kubernetes API server |
| Load balancer IPs | Varies by application | Reserve IPs in the same subnet as the Arc VM logical network, but outside the IP pool |

### Example Scenario

For a deployment with:
- Kubernetes cluster A: 3 control plane nodes and 5 worker nodes
- Kubernetes cluster B: 1 control plane node and 3 worker nodes
- 3 instances of a front-end UI service and 1 backend database

You would need to reserve:
- 8 IPs for cluster A node VMs
- 4 IPs for cluster B node VMs
- 2 IPs for AKS Arc upgrade operations (1 per cluster)
- 2 IPs for control plane access (1 per cluster)
- 3 IPs for Kubernetes services

Total: 19 IP addresses

## IP Address Ranges for Kubernetes Networking

### Pod Network CIDR

The Pod network CIDR is used by Kubernetes to assign unique IP addresses to individual pods. AKS on Azure Local uses Calico CNI in VXLAN mode, where pod IP addresses are virtualized and tunneled through the physical network.

- **Default value**: 10.244.0.0/16
- **Customization**: Can be set using the `--pod-cidr` parameter when creating the AKS cluster

Ensure the CIDR range is large enough to accommodate your maximum pod count across the Kubernetes cluster.

### Service Network CIDR

The Service network CIDR is used for Kubernetes services like LoadBalancers, ClusterIP, and NodePort within a cluster.

- **Default value**: 10.96.0.0/12
- **Customization**: Not currently supported in AKS on Azure Local

## Logical Network Considerations

You can configure logical networks for AKS clusters and Arc VMs in one of two ways:

### Shared Logical Network

**Benefits**:
- Streamlined communication
- Cost savings
- Simplified network management

**Challenges**:
- Resource contention
- Security risks
- Troubleshooting complexity

### Separate Logical Networks

**Benefits**:
- Better isolation and security
- Independent scalability
- Clearer network policy management

**Challenges**:
- More complex configuration
- Additional management overhead

## Implementation Example

Here's an example of how to create a logical network with an IP pool for AKS:

```powershell
$ipPoolStart = "10.220.32.18"
$ipPoolEnd = "10.220.32.37"

az stack-hci-vm network lnet create `
  --subscription $subscription `
  --resource-group $resource_group `
  --custom-location $customLocationID `
  --name $lnetName `
  --vm-switch-name $vmSwitchName `
  --ip-allocation-method "Static" `
  --address-prefixes $addressPrefixes `
  --gateway $gateway `
  --dns-servers $dnsServers `
  --ip-pool-start $ipPoolStart `
  --ip-pool-end $ipPoolEnd
```

Then create an AKS Arc cluster with this logical network:

```powershell
az aksarc create `
  -n $aksclustername `
  -g $resource_group `
  --custom-location $customlocationID `
  --vnet-ids $lnetName `
  --aad-admin-group-object-ids $aadgroupID `
  --generate-ssh-keys
```

## Best Practices

1. **Plan Ahead**: Reserve sufficient IP addresses for future growth
2. **Document Allocations**: Keep track of IP address assignments for troubleshooting
3. **Consider Subnet Sizing**: Ensure subnets are large enough for all components
4. **Use Different Ranges**: Keep pod and service CIDRs distinct from your physical network
5. **Plan for High Availability**: Reserve IPs for redundant components

By carefully planning your IP address strategy, you can ensure a smooth deployment and operation of your AKS clusters on Azure Local.
