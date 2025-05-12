# Sizing Examples for Kubernetes on Azure Local

## Example 1: Small Business Web Application
- **Workload**: 1 database, 2 application servers, 1 frontend
- **Traffic**: ~100 concurrent users
- **Resource Requirements**: 8 vCPU, 32GB RAM total
- **Recommended Configuration**: 
  - 3 physical nodes (16 cores, 64GB RAM each)
  - 2-way mirror Storage Spaces Direct
  - 1 Kubernetes control plane, 2 worker nodes

## Example 2: Medium Enterprise Application Suite
- **Workload**: 20+ microservices, 3 databases, message queue
- **Traffic**: ~1000 concurrent users
- **Resource Requirements**: 48 vCPU, 196GB RAM total
- **Recommended Configuration**:

## Example 3: Using the PowerShell Calculator for E-Commerce Platform

This example demonstrates using the [Azure Local Kubernetes PowerShell Calculator](../tools/AzureLocalK8sCalculator.ps1) to size a production e-commerce platform.

### Input Parameters

When running the calculator for this scenario, the following inputs were provided:

**Workload Types:**
1. **Web Frontend**
   - Pods: 5
   - CPU per pod: 0.5 cores
   - Memory per pod: 2 GB
   - Not stateful

2. **API Services**
   - Pods: 4
   - CPU per pod: 1 core
   - Memory per pod: 4 GB
   - Not stateful

3. **Product Catalog Service**
   - Pods: 2
   - CPU per pod: 2 cores
   - Memory per pod: 8 GB
   - Stateful

4. **Order Processing System**
   - Pods: 3
   - CPU per pod: 1 core
   - Memory per pod: 4 GB
   - Stateful

5. **Database**
   - Pods: 3
   - CPU per pod: 4 cores
   - Memory per pod: 16 GB
   - Stateful

**High Availability**: Yes (requires 3 control plane nodes)  
**Worker Node Minimum**: 3 nodes  
**Worker Node Size**: 8 vCPU, 32GB RAM per node  
**Control Plane Node Size**: 4 vCPU, 16GB RAM per node

### Calculator Results

The PowerShell Calculator provided the following results:

**Workload Summary:**
- Total Application Pods: 17
- Raw Application CPU Requirements: 24.50 cores
- Raw Application Memory Requirements: 98.00 GB

**Cluster Architecture:**
- High Availability: Yes
- Control Plane Nodes: 3
- Worker Nodes Required: 6
- Total Node Count: 9

**Virtual Machine Requirements:**
- Control Plane VM Specs: 4 vCPU, 16 GB RAM per node
- Worker VM Specs: 8 vCPU, 32 GB RAM per node
- Total VM CPU: 60.00 vCPU cores
- Total VM Memory: 240.00 GB

**Physical Host Requirements:**
- Minimum Physical CPU: 70.59 cores
- Minimum Physical Memory: 282.35 GB

**Storage Requirements:**
- Control Plane Storage: 384 GB
- Worker OS Storage: 768 GB
- Worker Data Storage: 2816.00 GB
- Total Storage Required: 3968.00 GB

**Recommended Azure Local Configuration:**
- Total Host Capacity Needed: At least 71 CPU cores, 283GB RAM
- Storage Pool Size: At least 4TB

### Implementation Decision

Based on these calculations, the organization deployed a 4-node Azure Local cluster using servers with 20 cores and 96GB RAM each, totaling 80 cores and 384GB RAM, which provides sufficient capacity plus room for growth.
  - 4 physical nodes (24+ cores, 256GB RAM each)
  - 3-way mirror Storage Spaces Direct
  - 3 Kubernetes control planes, 6+ worker nodes

## Example 3: Large Enterprise Microservices Platform
- **Workload**: 60+ microservices, 10+ databases, multiple message queues, batch processors
- **Traffic**: ~10,000+ concurrent users, heavy data processing
- **Resource Requirements**: 200 vCPU, 768GB RAM total
- **Recommended Configuration**:
  - 6-8 physical nodes (32+ cores, 512GB RAM each)
  - 3-way mirror Storage Spaces Direct with all-flash tier
  - 3 Kubernetes control planes, 12+ worker nodes
  - Dedicated physical nodes for storage-intensive workloads
  - Consider separating application tiers across different node pools