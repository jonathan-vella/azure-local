# Resource Calculation Tools for Azure Local Kubernetes

This document provides a list of resource calculation tools that can assist in precise sizing calculations for Kubernetes clusters on Azure Local. These tools help in analyzing resource allocation, estimating costs, and planning capacity effectively.

## Resource Calculation Tools

1. **Azure Local Kubernetes PowerShell Calculator**
   - An interactive PowerShell script that guides you through sizing your Kubernetes deployment on Azure Local.
   - Helps calculate resources based on workload requirements, high availability needs, and system overhead.
   - Provides recommendations for cluster architecture and host specifications.
   - Usage: Run `.\AzureLocalK8sCalculator.ps1` in PowerShell.
   - Location: [AzureLocalK8sCalculator.ps1](./AzureLocalK8sCalculator.ps1)

2. **Azure Pricing Calculator**
   - A tool for estimating Azure Arc licensing costs and other Azure services.
   - Link: [Azure Pricing Calculator](https://azure.microsoft.com/pricing/calculator/)

3. **Kubernetes Capacity Planner**
   - A tool for analyzing resource allocation within Kubernetes clusters.
   - GitHub Repository: [Kube Capacity](https://github.com/robscott/kube-capacity)

4. **Azure Local Capacity Planner**
   - Built-in capacity planning tool available in Windows Admin Center for Azure Local environments.

5. **Kubernetes Resource Calculator**
   - A web-based calculator to estimate pod and node resources based on workload requirements.
   - Link: [Kubernetes Resource Planning](https://learnk8s.io/kubernetes-instance-calculator)

## Usage Instructions

- Utilize these tools to gather data on your current workloads and resource requirements.
- Adjust your Kubernetes cluster sizing based on the insights gained from these calculations.
- Regularly revisit these tools as your application and infrastructure evolve to ensure optimal performance and cost-efficiency.

## Using the PowerShell Calculator

The PowerShell calculator (`AzureLocalK8sCalculator.ps1`) provides a guided approach to right-sizing your Kubernetes deployment:

1. **Define your workloads**: Specify the types of applications you'll run, pod counts, and resource requirements.
2. **Configure high availability**: Determine if you need redundancy and fault tolerance.
3. **Specify hardware constraints**: Enter the available resources per node.
4. **Get detailed recommendations**: The calculator will provide detailed sizing recommendations for your Azure Local environment.
5. **Save results**: Optionally save the results to a file for reference and planning.

This interactive calculator accounts for:
- Kubernetes system overhead
- Azure Arc management components
- High availability requirements
- Host OS and hypervisor overhead
- Storage needs for stateful workloads
- Resource utilization targets