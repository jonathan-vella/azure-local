# Autoscaling with AKS on Azure Local

This document provides guidance on leveraging the cluster autoscaler in AKS on Azure Local to automatically adjust the number of nodes based on workload demands.

## Overview

The cluster autoscaler component in AKS watches for pods that can't be scheduled due to resource constraints. When detected, it scales up the number of nodes in the node pool to meet application demands. It also regularly checks for underutilized nodes and scales down when appropriate.

## Enabling Cluster Autoscaler

### On a New Cluster

When creating a new AKS Arc cluster, you can enable and configure the cluster autoscaler using the `--enable-cluster-autoscaler` parameter with the `az aksarc create` command:

```powershell
az aksarc create `
  --resource-group myResourceGroup `
  --name my-aks-arc-cluster `
  --node-count 1 `
  --enable-cluster-autoscaler `
  --min-count 1 `
  --max-count 3
```

### On an Existing Cluster

For an existing AKS Arc cluster, use the `az aksarc update` command:

```powershell
az aksarc update `
  --resource-group myResourceGroup `
  --name my-aks-arc-cluster `
  --enable-cluster-autoscaler `
  --min-count 1 `
  --max-count 3
```

## Autoscaler Settings

You can adjust the following autoscaler settings based on your workload requirements:

### Adjusting Node Count Range

To update the minimum and maximum node counts:

```powershell
az aksarc update `
  --resource-group myResourceGroup `
  --name myAKSCluster `
  --update-cluster-autoscaler `
  --min-count 1 `
  --max-count 5
```

### Disabling the Autoscaler

To disable the autoscaler:

```powershell
az aksarc update `
  --resource-group myResourceGroup `
  --name my-aks-arc-cluster `
  --disable-cluster-autoscaler
```

## Cluster Autoscaler Profile

For more granular control, you can configure the autoscaler profile with settings such as:

| Setting | Description | Default |
|---------|-------------|---------|
| scan-interval | How often the cluster is reevaluated for scaling | 10 seconds |
| scale-down-delay-after-add | How long after scale up that scale down evaluation resumes | 10 minutes |
| scale-down-unneeded-time | How long a node should be unneeded before it's eligible for scale down | 10 minutes |
| scale-down-utilization-threshold | Node utilization level for scale down consideration | 0.5 |
| max-graceful-termination-sec | Maximum time to wait for pod termination when scaling down | 600 seconds |

### Setting the Autoscaler Profile

```powershell
az aksarc update `
  --resource-group myResourceGroup `
  --name my-aks-arc-cluster `
  --cluster-autoscaler-profile scan-interval=30s
```

## Scale Requirements and Limitations

When using the autoscaler with AKS on Azure Local, be aware of the following limitations:

- Maximum of 12 AKS clusters with autoscaler enabled per Azure Local environment
- Maximum of 4 concurrent AKS cluster creations
- Maximum of 4 concurrent node pool creations

If you exceed the supported cluster count, operations like creating additional clusters or node pools might not succeed, and existing clusters with autoscaler enabled may experience performance impacts.

## Best Practices

1. **Set Appropriate Pod Resource Requests**: The autoscaler uses pod resource requests to determine when to scale up nodes.

2. **Configure Proper Delays**: Set appropriate scale-down delays to prevent rapid scaling up and down during fluctuating loads.

3. **Monitor Autoscaling Events**: Regularly check autoscaling events to ensure the autoscaler is functioning as expected.

4. **Set Realistic Min/Max Values**: Configure min and max nodes based on your application's actual needs and available physical resources.

5. **Plan for Resource Requirements**: Ensure your Azure Local environment has sufficient resources to accommodate the maximum potential node count.

By effectively configuring and managing the cluster autoscaler, you can optimize resource utilization while ensuring your applications have the resources they need to run efficiently.
