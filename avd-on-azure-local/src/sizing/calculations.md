# Concrete Sizing Methodology

## Session Host VM Calculation Formula

1. **Base resource calculation**:
   - Total users × user type resource requirements = Base resources needed
   - **Example**: 100 knowledge workers × (2 vCPU, 8GB RAM) = 200 vCPU cores, 800GB RAM

2. **Concurrency adjustment**:
   - Base resources × peak concurrency percentage = Concurrent resources needed
   - Typical concurrency ranges from 60-80% for general users
   - **Example**: 200 vCPU, 800GB RAM × 70% concurrency = 140 vCPU cores, 560GB RAM needed

3. **Oversubscription calculation**:
   - Apply CPU oversubscription ratio based on user type
   - Light users: 6:1 to 8:1 (physical core:virtual core)
   - Medium users: 4:1 to 6:1
   - Heavy users: 2:1 to 4:1
   - Graphics users: 1:1 to 2:1
   - **Example**: 140 vCPU ÷ 5:1 ratio = 28 physical CPU cores

4. **High availability adjustment**:
   - Required resources × (N+1)/N = HA-adjusted resources
   - Where N = minimum number of session hosts needed
   - **Example**: With 5 session hosts: resources × (5+1)/5 = resources × 1.2 (20% additional)

5. **Resource overhead per host**:
   - Windows overhead: 2 vCPUs and 4GB RAM per host
   - Azure Local host OS: ~10% of host resources (Windows Server)
   - Virtual machine overhead: ~5% additional for hypervisor

6. **Session host count calculation**:
   - Total required resources ÷ resources per host = Number of session hosts
   - **Example**: If each host has 8 cores and 64GB RAM: 140 vCPU ÷ 8 = 18 session hosts

### Minimum Recommended Session Host Specifications

| User Type | vCPU/User | RAM/User | Min vCPU/Host | Min RAM/Host | Storage/Host |
|-----------|-----------|----------|--------------|--------------|--------------|
| Light Knowledge Worker | 2 | 4-8 GB | 8 | 32 GB | 128 GB OS, 64+ GB per user |
| Medium Knowledge Worker | 2-4 | 8-16 GB | 16 | 64 GB | 128 GB OS, 64+ GB per user |
| Power User | 4-8 | 16-32 GB | 16-24 | 96-128 GB | 128 GB OS, 100+ GB per user |
| Graphics Intensive | 4-8 | 16-32 GB | 16-24 | 96-128 GB | 128 GB OS, 100+ GB per user + GPU |

### Azure Local Resource Reservation Guidelines

| Component | CPU Reservation | Memory Reservation | Notes |
|-----------|----------------|-------------------|-------|
| Host OS (Windows Server) | 10% of physical cores | 4-8 GB per host | Higher for hosts with 256GB+ RAM |
| Azure Local management | 2-4 cores per host | 8-16 GB per host | Includes clustering, storage, etc. |
| Virtual Machine Overhead | 5% of VM allocation | 5% of VM allocation | Hypervisor overhead |
| Session Host Base OS | 2 cores per VM | 4 GB per VM | Minimum for reliable operation |
| User Session | Per user type | Per user type | See user type table |

**Note**: Always allocate at least 2 physical cores and 8GB RAM for the host OS and related services regardless of session host size.

## Storage Calculations

1. **OS Disk Storage**:
   - 128 GB per session host
   - Add 20% overhead for growth and updates

2. **User Profile Storage**:
   - FSLogix container size × number of users
   - Typical container size: 5-30 GB per user depending on profile complexity
   - Add 30% overhead for growth

3. **Application Storage**:
   - Base application footprint: 30-100 GB depending on applications
   - User data and cache: 10-20 GB per user
   - Add 25% overhead for updates and growth

4. **IOPS Requirements**:
   - Login storm: 10-30 IOPS per user (heavily dependent on profile size)
   - Steady state: 5-10 IOPS per user

## Network Bandwidth Calculations

1. **Internet Connectivity**:
   - Base bandwidth per concurrent user × number of concurrent users
   - Add 30% overhead for spikes
   - **Example**: 100 concurrent users × 2 Mbps = 200 Mbps × 1.3 = 260 Mbps minimum

2. **Internal Network**:
   - 10 Gbps minimum network connectivity between hosts and storage
   - Plan for redundant network paths for high availability
