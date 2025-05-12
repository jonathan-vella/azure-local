# Understanding User Workload Profiles

## User Types and Their Resource Requirements

### Knowledge Workers (Light)
- **CPU Requests**:
  - 2 vCPUs per session
- **Memory Requests**:
  - 4-8 GB RAM per session
- **Expected User Density**:
  - Up to 6 users per physical core (with hyperthreading)
- **Application Profile**:
  - Office applications (Word, Excel, Outlook)
  - Web browsing
  - PDF reading

### Knowledge Workers (Medium)
- **CPU Requests**:
  - 2-4 vCPUs per session
- **Memory Requests**:
  - 8-16 GB RAM per session
- **Expected User Density**:
  - 4-5 users per physical core (with hyperthreading)
- **Application Profile**:
  - Office applications with larger files
  - Multiple browser sessions with multiple tabs
  - Basic collaboration tools
  - Light data analysis

### Power Users
- **CPU Requests**:
  - 4-8 vCPUs per session
- **Memory Requests**:
  - 16-32 GB RAM per session
- **Expected User Density**:
  - 2-3 users per physical core (with hyperthreading)
- **Application Profile**:
  - Advanced data processing
  - Multiple concurrent applications
  - Data analysis tools
  - Development tools

### Graphics Intensive Users
- **CPU Requests**:
  - 4-8 vCPUs per session
- **Memory Requests**:
  - 16-32 GB RAM per session
- **GPU Requirements**:
  - Virtual GPU allocation (e.g., NVIDIA A-series)
- **Expected User Density**:
  - Based on GPU capacity, typically 2-4 users per GPU
- **Application Profile**:
  - CAD/CAM applications
  - 3D modeling
  - Video editing
  - Graphics design

## Load Expectations

### Session Patterns
- **Concurrent Sessions**:
  - Estimate peak concurrent sessions based on user work hours and patterns
- **Session Duration**:
  - Consider average session length (e.g., 4-8 hours for full-day workers, 1-2 hours for occasional access)
- **Login Storms**:
  - Account for peak login times (e.g., morning startup, after lunch)

### Resource Utilization
- **Average and Peak Usage**:
  - Estimate both average and peak resource utilization
- **Burst Requirements**:
  - Plan for short-term higher resource needs

## Storage Requirements

### User Profile Storage
- **Profile Size**:
  - Estimate average and max user profile sizes
- **Performance Needs**:
  - IOPS requirements for profile loading/saving
- **FSLogix Considerations**:
  - Storage requirements for FSLogix profile containers

### Application Storage
- **Application Installation Size**:
  - Calculate total space needed for all applications
- **Shared Content**:
  - Estimate space for shared application data

## Network Requirements

### Bandwidth Per User
- **Light Users**: 0.5-1 Mbps
- **Medium Users**: 1-2 Mbps
- **Heavy/Graphics Users**: 2-5+ Mbps

### Latency Sensitivity
- **Optimal Experience**: < 30ms
- **Good Experience**: 30-60ms
- **Acceptable Experience**: 60-100ms
- **Poor Experience**: > 100ms

## Peripheral and Special Requirements
- **USB Redirection**
- **Multiple Monitor Support**
- **Specialized Hardware Integration**
- **Audio/Video Conferencing Requirements**
