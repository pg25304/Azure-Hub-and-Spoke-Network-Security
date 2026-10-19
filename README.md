# Azure Hub-and-Spoke Network Security

## Project Overview

An independent, hands-on Microsoft Azure networking and cybersecurity project designed to implement and validate a secure hub-and-spoke architecture.

The project demonstrates network segmentation, centralised firewall management, traffic filtering, custom routing and connectivity testing using Azure services.

**Platform:** Microsoft Azure  
**Region:** UK South  
**Deployment:** Azure Portal (manual configuration)  
**Infrastructure as Code:** ARM JSON and Bicep exports

## Network Architecture

Three virtual networks were deployed with separate, non-overlapping address spaces.

| Network | Address space | Workload subnet |
|---|---|---|
| Hub | 192.168.1.0/24 | AzureFirewallSubnet: 192.168.1.0/26 |
| Spoke 1 (Application) | 192.168.2.0/24 | 192.168.2.0/27 |
| Spoke 2 (Database/Test) | 192.168.3.0/24 | 192.168.3.0/27 |

The Hub connects to both spokes through bidirectional VNet peering. The spokes are not directly peered with each other.

### Network Security

**Azure Firewall Standard**

- Deployed centrally within the Hub.
- Private IP address: `192.168.1.4`.
- Managed through Azure Firewall Policy.
- Network rules configured to permit TCP 8080 and TCP 3306 for specified inter-spoke communication.

**Network Security Groups**

- Separate NSGs associated with the application and database subnets.
- Custom inbound rules control access to the application workload.
- TCP 8080 permitted from Spoke 2 to Spoke 1.
- Other traffic from Spoke 2 to Spoke 1 restricted.

**User-Defined Routes**

| Source | Destination | Next hop |
|---|---|---|
| Spoke 1 | 192.168.3.0/27 | 192.168.1.4 |
| Spoke 2 | 192.168.2.0/27 | 192.168.1.4 |

Both routes were verified as active using Azure's Effective Routes feature.

## Virtual Machines

Two Ubuntu Server 24.04 LTS virtual machines were deployed using private IP addressing.

| VM | Private IP | Purpose |
|---|---|---|
| vm-spoke1-app | 192.168.2.4 | Application test server |
| vm-spoke2-db | 192.168.3.4 | Connectivity test client |

Both VMs used Trusted Launch, Secure Boot, vTPM and SSH key authentication, without public IP addresses.

Azure Run Command was used to administer and test the VMs.

## Security Validation

A Python HTTP service was configured on Spoke 1, listening on TCP port 8080.

| Test | Observed result |
|---|---|
| Spoke 2 → Spoke 1: TCP 8080 | Successful — HTTP 200 OK |
| Spoke 2 → Spoke 1: TCP 8081 | Connection timed out |
| Spoke 2 effective firewall route | Active |
| Spoke 1 effective firewall route | Active |
| Azure Firewall network rule metrics | Rule hits recorded |

The successful HTTP response demonstrated cross-spoke application connectivity. The TCP 8081 timeout demonstrated unsuccessful connectivity but did not independently establish which security control caused the failure.

Azure Firewall metrics and effective routing were examined as supporting evidence of centralised traffic processing.

The TCP 3306 rule was configured but no database connection test was performed.

## Evidence and Infrastructure

The project evidence collected includes:

- Configuration screenshots showing VNets, subnets, peering, NSGs and firewall rules.
- VM deployment and security configuration evidence.
- Application connectivity and routing test results.
- Exported ARM and Bicep infrastructure templates.

Exported infrastructure templates are retained as implementation references and require review and validation before reuse.

## Cost Management and Cleanup

The implementation used small Azure virtual machines and short deployment sessions to reduce costs.

After completing the practical tests and exporting the infrastructure configuration, the lab resource group was deleted to remove the deployed resources.

## Lessons Learned

This project strengthened practical understanding of:

- Hub-and-spoke network architecture and subnet planning.
- VNet peering and network segmentation.
- NSG filtering versus centralised firewall enforcement.
- User-defined routes and effective route verification.
- Secure administration of private Azure virtual machines.
- Infrastructure documentation, cost awareness and resource lifecycle management.

## Future Improvements

Future extensions could include Azure Firewall diagnostic logs with rule-level traffic validation, automated Bicep deployments, additional east-west traffic scenarios and broader application/database connectivity testing.

---

**Project type:** Independent cloud networking and cybersecurity portfolio project.

