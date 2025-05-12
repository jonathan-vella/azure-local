# High Availability and Resilience Requirements

## High Availability and Resilience Requirements (Considering Azure Local):

- **What is the required uptime and Service Level Objective (SLO) for the application?**
  
- **How much physical node failure can the Azure Local cluster tolerate while maintaining the required resources for the Kubernetes cluster and application pods?**
  - This relates to the number of Azure Local nodes and their configuration (e.g., 2-node, 3-node, or more).

- **How will planned maintenance on the Azure Local nodes be handled?**
  - Do you have enough overhead to evacuate and patch nodes without downtime for your Kubernetes applications?

- **How does the storage fault tolerance in Storage Spaces Direct (e.g., two-way mirror, three-way mirror) align with your application's data availability requirements?**