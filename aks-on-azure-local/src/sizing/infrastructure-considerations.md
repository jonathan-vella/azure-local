# Contents of /azure-local-kubernetes-docs/azure-local-kubernetes-docs/src/sizing/infrastructure-considerations.md

# Azure Local and Physical Infrastructure Considerations

- What are the specifications of your existing or planned Azure Local cluster nodes (CPU models and core counts, total RAM, storage capacity and types)?
  - This forms the fundamental resource pool for your Kubernetes cluster.
  
- How many nodes are in your Azure Local cluster?
  - This dictates the level of physical host redundancy available.
  
- What is the network configuration of the Azure Local cluster (network adapter speeds, switches)?
  - Network bottlenecks at the physical layer will impact Kubernetes pod-to-pod communication and traffic in and out of the cluster.
  
- What are the storage configurations on Azure Local (Storage Spaces Direct setup, drive types)?
  - This directly impacts the performance and capacity of Persistent Volumes used by your applications.
  
- What is the percentage overhead of the Azure Local operating system and other management components running on the physical nodes?
  - These resources are consumed before any resources are available for Kubernetes VMs.
  
- Are there other virtual machines or workloads running on the same Azure Local cluster?
  - Their resource consumption must be factored in when allocating resources for Kubernetes.
  
- What are the target CPU and memory utilization per node (60–75%)?
  
- Are there latency or throughput SLAs to meet?