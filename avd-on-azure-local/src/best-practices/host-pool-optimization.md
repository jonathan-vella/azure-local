# Host Pool Optimization for Azure Local Virtual Desktop

## Host Pool Design Considerations

### Session Host Distribution

- **Multiple Small Hosts vs. Fewer Large Hosts**:
  - Consider multiple smaller session hosts rather than fewer larger ones for better fault tolerance.
  - Recommendation: 4-16 vCPU per session host as a balanced approach.
  - Benefits: Better fault isolation, easier maintenance windows, more flexible scaling.

- **User Distribution Models**:
  - **Depth-first**: Fill one host before moving to next (optimizes for cost, reduces number of running VMs).
  - **Breadth-first**: Spread users across hosts evenly (optimizes for performance, reduces impact of noisy neighbors).
  - Recommendation: Use breadth-first for better user experience in most scenarios.

### Session Host Sizing

- **CPU Sizing**:
  - Avoid extreme oversubscription in Azure Local deployments.
  - Monitor CPU Ready/Wait times to detect oversubscription issues.
  - Conservative oversubscription ratios for Azure Local:
    - Light users: 4:1 to 6:1
    - Medium users: 3:1 to 4:1
    - Heavy users: 1:1 to 2:1

- **Memory Sizing**:
  - Never oversubscribe memory on Azure Local.
  - Reserve enough memory for the host OS and hypervisor (~15%).
  - Always account for Windows OS overhead (4GB minimum per session host).

- **Ephemeral OS Disk Considerations**:
  - Use ephemeral OS disks for session hosts when possible.
  - Benefits: Better performance, reduced storage costs, faster redeployments.
  - Requirements: Ensure host size supports ephemeral OS disk size needed.

## User Experience Optimization

### Profile Management

- **FSLogix Best Practices**:
  - Use FSLogix profile containers for all users.
  - Place profile containers on high-performance storage.
  - For Azure Local, consider:
    - Premium storage tier for profile containers
    - Container size between 5-30GB per user
    - Separate VHDX files for Office containers and profile containers

- **Profile Location**:
  - Use SMB file share hosted on Azure Local Storage Spaces Direct.
  - Ensure high availability of profile storage.
  - Consider disk-based backup of profile containers.

### Login Optimization

- **Pre-launch and Pre-population**:
  - Implement session host pre-launch during expected login storms.
  - Schedule VMs to start before peak login times.
  - Consider staggered login schedules if possible.

- **Drain Mode Strategy**:
  - Use drain mode for graceful maintenance.
  - Set hosts to drain mode several hours before maintenance.
  - Enable new connections after updates and validation.

## Resource Optimization

### Host Pool Scaling

- **Peak vs. Off-peak Hours**:
  - Implement automated scaling based on schedule and usage.
  - Scale hosts down during off-hours, weekends, and holidays.
  - Consider time to spin up VMs when setting scaling thresholds.

- **Burst Capacity**:
  - Reserve 20% capacity for unexpected bursts in usage.
  - Monitor session host performance and adjust capacity as needed.

### Auto-Scaling Best Practices

- **Scaling Parameters**:
  - Base on CPU threshold, user session counts, or schedule.
  - For Azure Local, conservative scale-in/out to prevent resource contention.
  - Recommended thresholds:
    - Scale out when CPU > 75% for 10 minutes
    - Scale in when CPU < 30% for 30 minutes

- **Sampling Window**:
  - Use longer sampling windows to avoid overreactions (10+ minutes).
  - Implement cool-down periods between scaling actions.

## Image Management

### Golden Image Maintenance

- **Image Update Strategy**:
  - Maintain a consistent golden image update schedule.
  - Test updates in staging/test host pools first.
  - Automate image updates using Azure Image Builder.

- **Application Layer Management**:
  - Consider Application Layering or MSIX App Attach for application management.
  - Separate OS, applications, and user data when possible.

### Optimization Recommendations

- **Session Host Optimization**:
  - Use the Virtual Desktop Optimization Tool (VDOT).
  - Disable unnecessary services and features for multi-session.
  - Remove pre-installed apps that aren't needed.
  - Apply GPOs specific to AVD performance.

- **User Environment Manager Settings**:
  - Configure environment variables for optimal performance.
  - Manage application policies centrally.
  - Use folder redirection judiciously.

## Monitoring and Management

### Proactive Monitoring

- **Key Metrics to Monitor**:
  - Host CPU, memory, and disk utilization
  - User session count and distribution
  - Login/logout times
  - Application performance metrics

- **Alerting Thresholds**:
  - Set alerts for resource constraints before users are impacted.
  - Monitor storage IOPS and latency closely.
  - Track user experience metrics.

### Health Checks

- **Regular Health Validation**:
  - Validate session host availability and performance.
  - Test user login experience regularly.
  - Monitor FSLogix profile health and capacity.

- **Maintenance Window Planning**:
  - Schedule regular maintenance windows.
  - Communicate maintenance schedules to users.
  - Implement gradual rollouts of any changes.
