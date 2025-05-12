# Azure Local Documentation

> **Disclaimer:** The information provided in this repository is for general guidance only and may not be accurate, complete, or up to date. Neither the contributors, repository owner, nor their employer assume any responsibility or liability for any errors, omissions, or outcomes resulting from the use of this documentation. Use at your own risk.

This repository contains comprehensive documentation for deploying and managing various Azure services on Azure Local environments. Azure Local provides a way to run Azure services on-premises, giving you the benefits of Azure while maintaining data and workloads in your own datacenter.

## Repository Structure

This documentation repository is organized into service-specific sections, each covering deployment, sizing, best practices, and operational guidance for a specific Azure service on Azure Local:

- 🐳 **[AKS on Azure Local](./aks-on-azure-local/README.md)**: Documentation for deploying and managing Azure Kubernetes Service (AKS) on Azure Local environments.
- 🖥️ **[AVD on Azure Local](./avd-on-azure-local/README.md)**: Documentation for deploying and managing Azure Virtual Desktop (AVD) on Azure Local environments.
- 🗄️ **[SQL MI on Azure Local](./sqlmi-on-azure-local/README.md)**: Documentation for deploying and managing Azure Arc-enabled SQL Managed Instance on Azure Local environments.

## Documentation Contents

Each service section includes:

### 📏 Sizing Documentation
- Workload analysis and categorization
- Infrastructure considerations
- High availability and disaster recovery planning
- Cost and licensing guidance
- Concrete sizing calculations and methodologies
- Capacity planning worksheets
- Real-world sizing examples

### ⭐ Best Practices
- Network configuration
- Storage recommendations
- Service-specific configuration guidance
- Performance optimization
- Security considerations

### 🛠️ Tools
- PowerShell calculators for resource sizing
- Resource planning tools
- Deployment scripts and templates

## 🚀 Getting Started

To get started with Azure Local documentation:

1. Choose the Azure service you want to deploy on Azure Local
2. Navigate to the corresponding folder in this repository
3. Start with the README.md file for an overview
4. Use the SUMMARY.md file for structured navigation through all documentation

## ✅ Prerequisites

- Azure Local environment or Azure Stack HCI
- Azure subscription for Arc integration
- Appropriate licenses for the services being deployed
- Network connectivity to Azure (for Arc-enabled services)

## 🤝 Contribution Guidelines

Contributions to improve the documentation are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request with a clear description of your improvements

## 📄 License

This project is licensed under the terms specified in the [LICENSE](./LICENSE) file.

## 💬 Support

For questions or issues related to this documentation, please create an issue in this repository.
