# Capacity Planning for Azure Local Kubernetes

## Capacity Planning Worksheet

### Step 1: Calculate Pod Resources
1. List each workload type and count: (Example: 3 web frontends, 2 APIs, 1 database)
2. Document resource requests per pod type:
   - Web frontend: 0.5 CPU, 1GB RAM
   - API service: 1 CPU, 2GB RAM
   - Database: 2 CPU, 8GB RAM
3. Calculate total: (3×0.5 + 2×1 + 1×2) = 5.5 CPU cores, (3×1 + 2×2 + 1×8) = 15GB RAM

### Step 2: Add Kubernetes System Overhead
- Add 20% to workload resources: 5.5 × 1.2 = 6.6 CPU, 15 × 1.2 = 18GB RAM
- Add control plane resources: 3 × 2 CPU = 6 CPU, 3 × 4GB = 12GB RAM
- Add Azure Arc components: ~10% additional overhead

### Step 3: Apply High-Availability Factor
- Ensure capacity when one node fails: Multiply by N+1/N
- For a 3-node worker cluster: × 4/3 = 1.33 factor

### Step 4: Determine Node Count and Specifications
- Divide total required resources by resources per node
- Consider standard Azure Local host sizes (optimize for your hardware)