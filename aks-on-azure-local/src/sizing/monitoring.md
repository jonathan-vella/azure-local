# Monitoring and Right-Sizing After Deployment

## Key Metrics to Track
- Node CPU/memory utilization (target: 60-75%)
- Pod resource utilization vs requests/limits
- Pod scheduling failures or pending pods
- Storage IOPS and latency

## Optimization Process
1. **Collection Phase** (2-4 weeks): Gather baseline metrics
2. **Analysis Phase**: Identify bottlenecks and overprovisioning
3. **Adjustment Phase**: Modify resource requests/limits and node allocation
4. **Validation Phase**: Confirm changes meet performance requirements

## Azure Monitor Integration
- Deploy Azure Monitor Container Insights via Azure Arc
  - Configure the Log Analytics workspace with optimized retention (30-90 days)
  - Enable metrics collection at 60-second intervals (default is 5 minutes)
- Create custom dashboards for Azure Local physical and virtual resource utilization
  - Monitor physical CPU, memory, and storage utilization across hosts
  - Track VM-to-host allocation ratios and overcommitment levels
- Set up alerts for resource constraints and performance degradation
  - Alert on node CPU > 80% for 15+ minutes
  - Alert on node memory > 85% for 10+ minutes
  - Alert on pending pods due to insufficient resources
  - Alert on storage latency > 10ms for critical workloads

## Key Monitoring Queries
// Node resource utilization
KubeNodeInventory
| join (Perf | where ObjectName == "K8SNode" | where CounterName == "cpuUsageNanoCores" or CounterName == "memoryRssBytes") on Computer
| summarize avg(CounterValue) by Computer, CounterName, bin(TimeGenerated, 1h)