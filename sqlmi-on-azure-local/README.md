# Azure Arc-enabled SQL Managed Instance on Azure Local

Welcome to the Azure Arc-enabled SQL Managed Instance on Azure Local Documentation project. This repository provides comprehensive guidance on sizing, best practices, and operational management for deploying SQL Managed Instance using Azure Arc data services on Azure Local environments.

## About Azure Arc-enabled SQL Managed Instance

Azure Arc-enabled SQL Managed Instance is a deployment option for SQL Server that provides near 100% compatibility with the latest SQL Server database engine. It allows you to deploy SQL Server instances on Azure Local infrastructure while benefiting from Azure cloud innovation and management capabilities through Azure Arc.

## Service Tiers

Azure Arc-enabled SQL Managed Instance offers two service tiers:

- **General Purpose**: Cost-effective option using remote storage, suitable for most business workloads
- **Business Critical**: Premium offering with local storage and built-in high availability using Always On Availability Groups

## Project Structure

The documentation is organized into several key sections:

- **Sizing**: Detailed information on how to size your SQL Managed Instance deployment effectively, including:
  - Understanding the SQL MI database workload types
  - SQL MI infrastructure considerations
  - High availability options with Business Critical tier
  - Cost and licensing aspects
  - Operational overhead and management
  - Azure Arc integration and services
  - Concrete sizing calculations for SQL MI and data controller
  - Practical sizing examples with different workloads

- **Tools**: Practical tools to assist in planning and managing your deployment:
  - [PowerShell Sizing Calculator](./src/tools/AzureLocalSqlMICalculator.ps1): An interactive script that guides you through the process of properly sizing your Azure Arc SQL Managed Instance environment
  - Resource calculation tools specific to SQL MI
  - Capacity planning worksheets for different service tiers
  - Monitoring strategies post-deployment

- **Best Practices**: Guidelines for optimizing your Azure Arc SQL Managed Instance setup, covering:
  - Network configuration and security
  - Storage configuration for different service tiers
  - Instance configuration and management
  - Performance tuning and monitoring
  - Security considerations and best practices
  - Kubernetes integration and management

- **Tools**: A section dedicated to resource calculation tools and utilities specifically for SQL MI deployments.

- **Images**: A directory for storing relevant diagrams and architecture images for SQL MI deployments.

- **SUMMARY.md**: A summary or table of contents linking to the various markdown files for easy navigation.

## Key Features of Azure Arc-enabled SQL MI

- Near 100% compatibility with on-premises SQL Server
- Built-in high availability with Business Critical tier
- Azure management capabilities through Azure Arc
- Consistent security and governance through Azure Policy
- Flexible deployment options on Azure Local infrastructure
- Familiar SQL Server tools and features
- Azure Monitor integration for observability

## Getting Started

To get started with Azure Arc-enabled SQL Managed Instance on Azure Local:

1. Clone this repository to your local machine.
2. Navigate to the `src` directory to explore the documentation.
3. Use the `SUMMARY.md` file as a guide to navigate through the content.
4. Review the sizing guidance to determine your resource requirements.
5. Follow best practices for deploying SQL MI in your environment.

## Prerequisites

- Azure Local infrastructure or Azure Stack HCI
- Kubernetes cluster (version 1.23 or later)
- Azure subscription for Arc integration
- Network connectivity to Azure

## Contribution

Contributions to improve the documentation are welcome! Please feel free to submit issues or pull requests for any enhancements or corrections.

## License

This project is licensed under the MIT License. See the LICENSE file for more details.

For any questions or feedback, please reach out to the maintainers of this project. Happy documenting!
