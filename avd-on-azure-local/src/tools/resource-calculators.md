# Resource Calculation Tools for Azure Local Virtual Desktop

This document provides a list of resource calculation tools that can assist in precise sizing calculations for Azure Virtual Desktop deployments on Azure Local. These tools help in analyzing resource allocation, estimating costs, and planning capacity effectively.

## Resource Calculation Tools

1. **Azure Local Virtual Desktop PowerShell Calculator**
   - An interactive PowerShell script that guides you through sizing your AVD deployment on Azure Local.
   - Helps calculate resources based on user profiles, concurrency needs, and system overhead.
   - Provides recommendations for host pool architecture and host specifications.
   - Usage: Run `.\AzureLocalAVDCalculator.ps1` in PowerShell.
   - Location: [AzureLocalAVDCalculator.ps1](./AzureLocalAVDCalculator.ps1)

2. **Azure Pricing Calculator**
   - A tool for estimating Azure Arc licensing costs, AVD licensing, and other Azure services.
   - Link: [Azure Pricing Calculator](https://azure.microsoft.com/pricing/calculator/)

3. **AVD Scaling Tool**
   - A tool for analyzing user session patterns and optimizing scaling of session hosts.
   - Link: [AVD Auto-Scaling Tool](https://github.com/Azure/AVD-Auto-Scale-Tool)

4. **Azure Local Capacity Planner**
   - Built-in capacity planning tool available in Windows Admin Center for Azure Local environments.

5. **Virtual Desktop Optimization Tool**
   - A tool for optimizing Windows 10/11 multi-session and Windows Server images for AVD.
   - Link: [Virtual Desktop Optimization Tool](https://github.com/The-Virtual-Desktop-Team/Virtual-Desktop-Optimization-Tool)

## Usage Instructions

- Utilize these tools to gather data on your user profiles and resource requirements.
- Adjust your AVD deployment sizing based on the insights gained from these calculations.
- Regularly revisit these tools as your user patterns and infrastructure evolve to ensure optimal performance and cost-efficiency.

## Using the PowerShell Calculator

The PowerShell calculator (`AzureLocalAVDCalculator.ps1`) provides a guided approach to right-sizing your AVD deployment:

1. **Define your user profiles**: Specify the types of users you'll support, counts, and resource requirements.
2. **Configure high availability**: Determine if you need redundancy and fault tolerance.
3. **Specify hardware constraints**: Enter the available resources per host.
4. **Get detailed recommendations**: The calculator will provide detailed sizing recommendations for your Azure Local environment.
5. **Save results**: Optionally save the results to a file for reference and planning.

This interactive calculator accounts for:
- User profile resource requirements
- Session concurrency patterns
- CPU oversubscription ratios
- High availability requirements
- Host OS and hypervisor overhead
- Storage needs for user profiles and applications
- Network bandwidth requirements
