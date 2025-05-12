# Contents of /azure-local-kubernetes-docs/azure-local-kubernetes-docs/src/sizing/application-workload.md

# Understanding the Application Workload

## Resource Requirements of Application Components

- **CPU Requests and Limits**:
  - Determine the minimum and maximum CPU requests and limits for each pod.
  
- **Memory Requests and Limits**:
  - Identify the minimum and maximum memory requests and limits for each pod.

- **Expected Number of Pods**:
  - Assess the expected number of pods per application, including minimum, average, and maximum counts.

- **High Resource Usage Pods**:
  - Identify any pods that have high resource usage, such as machine learning workloads or Java Virtual Machines (JVMs).

- **Specialized Hardware Needs**:
  - Determine if any workloads require GPU support or other specialized hardware.

## Load Expectations

- **Average and Peak Load**:
  - Estimate the expected average and peak load on the application, including requests per second, minute, or hour.

- **Data Processing Volumes**:
  - Analyze typical data processing volumes.

- **Traffic Spikes**:
  - Identify specific times or events that may cause significant spikes in traffic or resource usage.

- **Duration of Peak Loads**:
  - Understand how long peak loads typically last.

## Stateful Components

- **Storage Requirements**:
  - If the application has stateful components, determine their storage requirements, including IOPS, throughput, and capacity.

- **Node Affinity Needs**:
  - Assess if there are specific node affinity or anti-affinity needs for performance or data locality on the Azure Local cluster.

- **Storage Performance**:
  - Evaluate the kind of storage performance provided by the underlying Azure Local storage pool (e.g., all-flash, hybrid).

## Background Processes

- **Resource Demands**:
  - Identify any background processes or batch jobs that run periodically and their resource demands.

- **Scheduling**:
  - Determine if these processes can be scheduled during off-peak hours to minimize impact on interactive workloads.

## Network Traffic Patterns

- **Traffic Between Components**:
  - Analyze the network traffic pattern between application components and external services, both within the local network and to Azure.

- **Bandwidth Requirements**:
  - Identify any components with high ingress or egress bandwidth requirements that could impact the local network infrastructure.