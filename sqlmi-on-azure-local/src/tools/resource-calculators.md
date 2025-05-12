# Resource Calculation Tools for Azure Arc-enabled SQL Managed Instance

This document provides a list of resource calculation tools that can assist in precise sizing calculations for Azure Arc-enabled SQL Managed Instance deployments on Azure Local. These tools help in analyzing resource requirements, estimating costs, and planning capacity effectively.

## Resource Calculation Tools

1. **Azure Local SQL Managed Instance PowerShell Calculator**
   - An interactive PowerShell script that guides you through sizing your SQL MI deployment on Azure Local
   - Helps calculate resources based on database workload characteristics, service tier, high availability needs, and system overhead
   - Provides recommendations for instance size and host specifications
   - Accounts for both General Purpose and Business Critical tiers
   - Usage: Run `.\AzureLocalSqlMICalculator.ps1` in PowerShell
   - Location: [AzureLocalSqlMICalculator.ps1](./AzureLocalSqlMICalculator.ps1)

2. **Azure Arc Data Services Deployment Planning Guide**
   - Official Microsoft tool for planning Azure Arc data services deployments
   - Provides guidance on sizing and deployment architecture
   - Link: [Azure Arc Data Services Planning](https://learn.microsoft.com/en-us/azure/azure-arc/data/sizing-guidance)

3. **Azure Pricing Calculator**
   - Tool for estimating Azure Arc licensing costs, SQL MI licensing, and other Azure services
   - Allows comparison between different service tiers and configurations
   - Link: [Azure Pricing Calculator](https://azure.microsoft.com/pricing/calculator/)

4. **Performance Dashboard for Azure SQL Managed Instance**
   - Monitoring tool for deployed SQL MI instances
   - Helps identify performance issues and optimization opportunities
   - Link: [SQL MI Performance Dashboard](https://learn.microsoft.com/en-us/azure/azure-sql/database/query-performance-insight-use)

5. **Azure Arc Data Controller Size Estimator**
   - Tool for sizing the data controller component required for SQL MI
   - Helps determine resource requirements for the control plane
   - Link: [Azure Arc Data Controller Sizing](https://learn.microsoft.com/en-us/azure/azure-arc/data/sizing-guidance#azure-arc-data-controller-sizing)

6. **SQL Server Capacity Planning Assistant**
   - Provides guidance on SQL Server capacity planning
   - Useful for workload analysis prior to migration to SQL MI
   - Helps determine appropriate service tier and resource allocation
   - Link: [SQL Server Capacity Planning](https://www.microsoft.com/en-us/download/details.aspx?id=30133)

## Using the PowerShell Calculator

The PowerShell calculator (`AzureLocalSqlMICalculator.ps1`) provides a guided approach to right-sizing your SQL MI deployment on Azure Local:

1. **Basic or Advanced Mode**:
   - Basic mode: Quick sizing for standard deployments
   - Advanced mode: Detailed sizing with HA options and growth projections

2. **Service Tier Selection**:
   - General Purpose: Remote storage, good for most workloads
   - Business Critical: Local storage, high performance, built-in HA

3. **Workload Configuration**:
   - Specify database size, user count, and transaction rates
   - Define workload type (OLTP, OLAP, mixed)
   - Account for future growth and expansion

4. **Get Recommendations**:
   - Calculator provides specific resource recommendations
   - Results include CPU, memory, and storage requirements
   - Accounts for data controller and system overhead
   - Provides total host sizing including recommended buffer

## Best Practices for Resource Calculation

- Start with a detailed analysis of your current database workloads
- Right-size your SQL MI instances based on actual performance requirements
- Include overhead for the Azure Arc data controller
- Account for high availability requirements in your capacity planning
- Allow for future growth in your resource allocations
- Regularly review and adjust resource allocations based on performance data
- Consider separating workloads across multiple instances when appropriate
- Network bandwidth requirements
