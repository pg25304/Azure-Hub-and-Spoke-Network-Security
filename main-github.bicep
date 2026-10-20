@description('Supply your own Spoke 1 SSH public key at deployment; never publish a private key.')
@secure()
param sshPublicKeySpoke1 string
@description('Supply your own Spoke 2 SSH public key at deployment; never publish a private key.')
@secure()
param sshPublicKeySpoke2 string

param sshPublicKeys_key_spoke2_db_name string = 'key-spoke2-db'
param sshPublicKeys_key_spoke1_app_name string = 'key-spoke1-app'
param virtualMachines_vm_spoke2_db_name string = 'vm-spoke2-db'
param virtualMachines_vm_spoke1_app_name string = 'vm-spoke1-app'
param routeTables_rt_spoke1_security_name string = 'rt-spoke1-security'
param routeTables_rt_spoke2_security_name string = 'rt-spoke2-security'
param networkInterfaces_vm_spoke2_db828_name string = 'vm-spoke2-db828'
param azureFirewalls_fw_hub_security_lab_name string = 'fw-hub-security-lab'
param networkInterfaces_vm_spoke1_app952_name string = 'vm-spoke1-app952'
param publicIPAddresses_pip_hub_firewall_name string = 'pip-hub-firewall'
param networkSecurityGroups_nsg_spoke2_db_name string = 'nsg-spoke2-db'
param networkSecurityGroups_nsg_spoke1_app_name string = 'nsg-spoke1-app'
param virtualNetworks_vnet_hub_security_lab_name string = 'vnet-hub-security-lab'
param firewallPolicies_fw_policy_hub_security_name string = 'fw-policy-hub-security'
param virtualNetworks_vnet_spoke1_security_lab_name string = 'vnet-spoke1-security-lab'
param virtualNetworks_vnet_spoke2_security_lab_name string = 'vnet-spoke2-security-lab'
param schedules_shutdown_computevm_vm_spoke2_db_name string = 'shutdown-computevm-vm-spoke2-db'
param schedules_shutdown_computevm_vm_spoke1_app_name string = 'shutdown-computevm-vm-spoke1-app'

resource sshPublicKeys_key_spoke1_app_name_resource 'Microsoft.Compute/sshPublicKeys@2026-04-01' = {
  name: sshPublicKeys_key_spoke1_app_name
  location: 'uksouth'
  properties: {
    publicKey: sshPublicKeySpoke1
  }
}

resource sshPublicKeys_key_spoke2_db_name_resource 'Microsoft.Compute/sshPublicKeys@2026-04-01' = {
  name: sshPublicKeys_key_spoke2_db_name
  location: 'uksouth'
  properties: {
    publicKey: sshPublicKeySpoke2
  }
}

resource firewallPolicies_fw_policy_hub_security_name_resource 'Microsoft.Network/firewallPolicies@2025-09-01' = {
  name: firewallPolicies_fw_policy_hub_security_name
  location: 'uksouth'
  properties: {
    sku: {
      tier: 'Standard'
    }
    threatIntelMode: 'Alert'
  }
}

resource networkSecurityGroups_nsg_spoke1_app_name_resource 'Microsoft.Network/networkSecurityGroups@2025-09-01' = {
  name: networkSecurityGroups_nsg_spoke1_app_name
  location: 'uksouth'
  tags: {
    Project: 'Hub-Spoke-Security'
  }
  properties: {
    securityRules: [
      {
        name: 'Allow-Spoke2-to-App-8080'
        id: networkSecurityGroups_nsg_spoke1_app_name_Allow_Spoke2_to_App_8080.id
        properties: {
          sourcePortRange: '*'
          destinationPortRange: '8080'
          sourceAddressPrefix: '192.168.3.0/27'
          destinationAddressPrefix: '192.168.2.0/27'
          priority: 100
          description: 'Allow Spoke 2 to access application on TCP 8080'
          protocol: 'TCP'
          access: 'Allow'
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'Deny-Spoke2-Other-Traffic'
        id: networkSecurityGroups_nsg_spoke1_app_name_Deny_Spoke2_Other_Traffic.id
        properties: {
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '192.168.3.0/27'
          destinationAddressPrefix: '192.168.2.0/27'
          priority: 110
          description: 'Block other traffic from Spoke 2'
          protocol: '*'
          access: 'Deny'
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
    ]
  }
}

resource networkSecurityGroups_nsg_spoke2_db_name_resource 'Microsoft.Network/networkSecurityGroups@2025-09-01' = {
  name: networkSecurityGroups_nsg_spoke2_db_name
  location: 'uksouth'
  tags: {
    Project: 'Hub-Spoke-Security'
  }
  properties: {
    securityRules: [
      {
        name: 'Allow-Spoke1-to-DB-3306'
        id: networkSecurityGroups_nsg_spoke2_db_name_Allow_Spoke1_to_DB_3306.id
        properties: {
          sourcePortRange: '*'
          destinationPortRange: '3306'
          sourceAddressPrefix: '192.168.2.0/27'
          destinationAddressPrefix: '192.168.3.0/27'
          priority: 100
          description: 'Allow application subnet to access MySQL'
          protocol: 'TCP'
          access: 'Allow'
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'Deny-Spoke1-Other-Traffic'
        id: networkSecurityGroups_nsg_spoke2_db_name_Deny_Spoke1_Other_Traffic.id
        properties: {
          sourcePortRange: '*'
          destinationPortRange: '8080'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          priority: 110
          description: 'Block other traffic from Spoke 1'
          protocol: '*'
          access: 'Allow'
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
    ]
  }
}

resource publicIPAddresses_pip_hub_firewall_name_resource 'Microsoft.Network/publicIPAddresses@2025-09-01' = {
  name: publicIPAddresses_pip_hub_firewall_name
  location: 'uksouth'
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
    ipTags: []
  }
}

resource routeTables_rt_spoke1_security_name_resource 'Microsoft.Network/routeTables@2025-09-01' = {
  name: routeTables_rt_spoke1_security_name
  location: 'uksouth'
  tags: {
    Project: 'Hub-Spoke-Security'
  }
  properties: {
    disableBgpRoutePropagation: false
    routes: [
      {
        name: 'route-to-spoke2-via-firewall'
        id: routeTables_rt_spoke1_security_name_route_to_spoke2_via_firewall.id
        properties: {
          addressPrefix: '192.168.3.0/27'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: '192.168.1.4'
        }
      }
    ]
  }
}

resource routeTables_rt_spoke2_security_name_resource 'Microsoft.Network/routeTables@2025-09-01' = {
  name: routeTables_rt_spoke2_security_name
  location: 'uksouth'
  tags: {
    Project: 'Hub-Spoke-Security'
  }
  properties: {
    disableBgpRoutePropagation: true
    routes: [
      {
        name: 'route-to-spoke1-via-firewall'
        id: routeTables_rt_spoke2_security_name_route_to_spoke1_via_firewall.id
        properties: {
          addressPrefix: '192.168.2.0/27'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: '192.168.1.4'
        }
      }
    ]
  }
}

resource virtualMachines_vm_spoke1_app_name_resource 'Microsoft.Compute/virtualMachines@2026-04-01' = {
  name: virtualMachines_vm_spoke1_app_name
  location: 'uksouth'
  tags: {
    Project: 'Hub-Spoke-Security'
  }
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B1s'
    }
    additionalCapabilities: {
      hibernationEnabled: false
    }
    storageProfile: {
      imageReference: {
        publisher: 'canonical'
        offer: 'ubuntu-24_04-lts'
        sku: 'server'
        version: 'latest'
      }
      osDisk: {
        osType: 'Linux'
        name: '${virtualMachines_vm_spoke1_app_name}_OsDisk_1_95271b344a124fa7a3321ed56a1f4047'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'StandardSSD_ZRS'
          id: resourceId(
            'Microsoft.Compute/disks',
            '${virtualMachines_vm_spoke1_app_name}_OsDisk_1_95271b344a124fa7a3321ed56a1f4047'
          )
        }
        deleteOption: 'Delete'
        diskSizeGB: 30
      }
      dataDisks: []
      diskControllerType: 'SCSI'
    }
    osProfile: {
      computerName: virtualMachines_vm_spoke1_app_name
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/azureuser/.ssh/authorized_keys'
              keyData: sshPublicKeySpoke1
            }
          ]
        }
        provisionVMAgent: true
        patchSettings: {
          patchMode: 'ImageDefault'
          assessmentMode: 'ImageDefault'
        }
        enableVMAgentPlatformUpdates: true
      }
      secrets: []
      allowExtensionOperations: true
      requireGuestProvisionSignal: true
      adminUsername: 'azureuser'
    }
    securityProfile: {
      uefiSettings: {
        secureBootEnabled: true
        vTpmEnabled: true
      }
      securityType: 'TrustedLaunch'
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterfaces_vm_spoke1_app952_name_resource.id
          properties: {
            deleteOption: 'Delete'
          }
        }
      ]
    }
  }
}

resource virtualMachines_vm_spoke2_db_name_resource 'Microsoft.Compute/virtualMachines@2026-04-01' = {
  name: virtualMachines_vm_spoke2_db_name
  location: 'uksouth'
  tags: {
    Project: 'Hub-Spoke-Security'
  }
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B1s'
    }
    additionalCapabilities: {
      hibernationEnabled: false
    }
    storageProfile: {
      imageReference: {
        publisher: 'canonical'
        offer: 'ubuntu-24_04-lts'
        sku: 'server'
        version: 'latest'
      }
      osDisk: {
        osType: 'Linux'
        name: '${virtualMachines_vm_spoke2_db_name}_disk1_4340a13a81d14e769306ed37d9113db2'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
          id: resourceId(
            'Microsoft.Compute/disks',
            '${virtualMachines_vm_spoke2_db_name}_disk1_4340a13a81d14e769306ed37d9113db2'
          )
        }
        deleteOption: 'Delete'
        diskSizeGB: 30
      }
      dataDisks: []
      diskControllerType: 'SCSI'
    }
    osProfile: {
      computerName: virtualMachines_vm_spoke2_db_name
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/azureuser/.ssh/authorized_keys'
              keyData: sshPublicKeySpoke2
            }
          ]
        }
        provisionVMAgent: true
        patchSettings: {
          patchMode: 'ImageDefault'
          assessmentMode: 'ImageDefault'
        }
        enableVMAgentPlatformUpdates: true
      }
      secrets: []
      allowExtensionOperations: true
      requireGuestProvisionSignal: true
      adminUsername: 'azureuser'
    }
    securityProfile: {
      uefiSettings: {
        secureBootEnabled: true
        vTpmEnabled: true
      }
      securityType: 'TrustedLaunch'
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterfaces_vm_spoke2_db828_name_resource.id
          properties: {
            deleteOption: 'Delete'
          }
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

resource schedules_shutdown_computevm_vm_spoke1_app_name_resource 'microsoft.devtestlab/schedules@2018-09-15' = {
  name: schedules_shutdown_computevm_vm_spoke1_app_name
  location: 'uksouth'
  tags: {
    Project: 'Hub-Spoke-Security'
  }
  properties: {
    status: 'Enabled'
    taskType: 'ComputeVmShutdownTask'
    dailyRecurrence: {
      time: '1900'
    }
    timeZoneId: 'GMT Standard Time'
    notificationSettings: {
      status: 'Disabled'
      timeInMinutes: 30
      notificationLocale: 'en'
    }
    targetResourceId: virtualMachines_vm_spoke1_app_name_resource.id
  }
}

resource schedules_shutdown_computevm_vm_spoke2_db_name_resource 'microsoft.devtestlab/schedules@2018-09-15' = {
  name: schedules_shutdown_computevm_vm_spoke2_db_name
  location: 'uksouth'
  tags: {
    Project: 'Hub-Spoke-Security'
  }
  properties: {
    status: 'Enabled'
    taskType: 'ComputeVmShutdownTask'
    dailyRecurrence: {
      time: '1900'
    }
    timeZoneId: 'GMT Standard Time'
    notificationSettings: {
      status: 'Disabled'
      timeInMinutes: 30
      notificationLocale: 'en'
    }
    targetResourceId: virtualMachines_vm_spoke2_db_name_resource.id
  }
}

resource firewallPolicies_fw_policy_hub_security_name_DefaultNetworkRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2025-09-01' = {
  parent: firewallPolicies_fw_policy_hub_security_name_resource
  name: 'DefaultNetworkRuleCollectionGroup'
  location: 'uksouth'
  properties: {
    priority: 200
    ruleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'NetworkRule'
            name: 'Allow-Spoke2-to-App-8080'
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: [
              '192.168.3.0/27'
            ]
            sourceIpGroups: []
            destinationAddresses: [
              '192.168.2.0/27'
            ]
            destinationIpGroups: []
            destinationFqdns: []
            destinationPorts: [
              '8080'
            ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'Allow-Spoke1-to-DB-3306'
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: [
              '192.168.2.0/27'
            ]
            sourceIpGroups: []
            destinationAddresses: [
              '192.168.3.0/27'
            ]
            destinationIpGroups: []
            destinationFqdns: []
            destinationPorts: [
              '3306'
            ]
          }
        ]
        name: 'rc-allow-spoke-traffic'
        priority: 100
      }
    ]
  }
}

resource networkInterfaces_vm_spoke1_app952_name_resource 'Microsoft.Network/networkInterfaces@2025-09-01' = {
  name: networkInterfaces_vm_spoke1_app952_name
  location: 'uksouth'
  tags: {
    Project: 'Hub-Spoke-Security'
  }
  kind: 'Regular'
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        id: '${networkInterfaces_vm_spoke1_app952_name_resource.id}/ipConfigurations/ipconfig1'
        properties: {
          privateIPAddress: '192.168.2.4'
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: virtualNetworks_vnet_spoke1_security_lab_name_snet_spoke1_app.id
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    dnsSettings: {
      dnsServers: []
    }
    enableIPForwarding: false
    disableTcpStateTracking: false
    nicType: 'Standard'
    auxiliaryMode: 'None'
    auxiliarySku: 'None'
  }
}

resource networkInterfaces_vm_spoke2_db828_name_resource 'Microsoft.Network/networkInterfaces@2025-09-01' = {
  name: networkInterfaces_vm_spoke2_db828_name
  location: 'uksouth'
  tags: {
    Project: 'Hub-Spoke-Security'
  }
  kind: 'Regular'
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        id: '${networkInterfaces_vm_spoke2_db828_name_resource.id}/ipConfigurations/ipconfig1'
        properties: {
          privateIPAddress: '192.168.3.4'
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: virtualNetworks_vnet_spoke2_security_lab_name_snet_spoke2_db.id
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    dnsSettings: {
      dnsServers: []
    }
    enableIPForwarding: false
    disableTcpStateTracking: false
    nicType: 'Standard'
    auxiliaryMode: 'None'
    auxiliarySku: 'None'
  }
}

resource networkSecurityGroups_nsg_spoke2_db_name_Allow_Spoke1_to_DB_3306 'Microsoft.Network/networkSecurityGroups/securityRules@2025-09-01' = {
  name: '${networkSecurityGroups_nsg_spoke2_db_name}/Allow-Spoke1-to-DB-3306'
  properties: {
    sourcePortRange: '*'
    destinationPortRange: '3306'
    sourceAddressPrefix: '192.168.2.0/27'
    destinationAddressPrefix: '192.168.3.0/27'
    priority: 100
    description: 'Allow application subnet to access MySQL'
    protocol: 'TCP'
    access: 'Allow'
    direction: 'Inbound'
    sourcePortRanges: []
    destinationPortRanges: []
    sourceAddressPrefixes: []
    destinationAddressPrefixes: []
  }
  dependsOn: [
    networkSecurityGroups_nsg_spoke2_db_name_resource
  ]
}

resource networkSecurityGroups_nsg_spoke1_app_name_Allow_Spoke2_to_App_8080 'Microsoft.Network/networkSecurityGroups/securityRules@2025-09-01' = {
  name: '${networkSecurityGroups_nsg_spoke1_app_name}/Allow-Spoke2-to-App-8080'
  properties: {
    sourcePortRange: '*'
    destinationPortRange: '8080'
    sourceAddressPrefix: '192.168.3.0/27'
    destinationAddressPrefix: '192.168.2.0/27'
    priority: 100
    description: 'Allow Spoke 2 to access application on TCP 8080'
    protocol: 'TCP'
    access: 'Allow'
    direction: 'Inbound'
    sourcePortRanges: []
    destinationPortRanges: []
    sourceAddressPrefixes: []
    destinationAddressPrefixes: []
  }
  dependsOn: [
    networkSecurityGroups_nsg_spoke1_app_name_resource
  ]
}

resource networkSecurityGroups_nsg_spoke2_db_name_Deny_Spoke1_Other_Traffic 'Microsoft.Network/networkSecurityGroups/securityRules@2025-09-01' = {
  name: '${networkSecurityGroups_nsg_spoke2_db_name}/Deny-Spoke1-Other-Traffic'
  properties: {
    sourcePortRange: '*'
    destinationPortRange: '8080'
    sourceAddressPrefix: '*'
    destinationAddressPrefix: '*'
    priority: 110
    description: 'Block other traffic from Spoke 1'
    protocol: '*'
    access: 'Allow'
    direction: 'Inbound'
    sourcePortRanges: []
    destinationPortRanges: []
    sourceAddressPrefixes: []
    destinationAddressPrefixes: []
  }
  dependsOn: [
    networkSecurityGroups_nsg_spoke2_db_name_resource
  ]
}

resource networkSecurityGroups_nsg_spoke1_app_name_Deny_Spoke2_Other_Traffic 'Microsoft.Network/networkSecurityGroups/securityRules@2025-09-01' = {
  name: '${networkSecurityGroups_nsg_spoke1_app_name}/Deny-Spoke2-Other-Traffic'
  properties: {
    sourcePortRange: '*'
    destinationPortRange: '*'
    sourceAddressPrefix: '192.168.3.0/27'
    destinationAddressPrefix: '192.168.2.0/27'
    priority: 110
    description: 'Block other traffic from Spoke 2'
    protocol: '*'
    access: 'Deny'
    direction: 'Inbound'
    sourcePortRanges: []
    destinationPortRanges: []
    sourceAddressPrefixes: []
    destinationAddressPrefixes: []
  }
  dependsOn: [
    networkSecurityGroups_nsg_spoke1_app_name_resource
  ]
}

resource routeTables_rt_spoke2_security_name_route_to_spoke1_via_firewall 'Microsoft.Network/routeTables/routes@2025-09-01' = {
  name: '${routeTables_rt_spoke2_security_name}/route-to-spoke1-via-firewall'
  properties: {
    addressPrefix: '192.168.2.0/27'
    nextHopType: 'VirtualAppliance'
    nextHopIpAddress: '192.168.1.4'
  }
  dependsOn: [
    routeTables_rt_spoke2_security_name_resource
  ]
}

resource routeTables_rt_spoke1_security_name_route_to_spoke2_via_firewall 'Microsoft.Network/routeTables/routes@2025-09-01' = {
  name: '${routeTables_rt_spoke1_security_name}/route-to-spoke2-via-firewall'
  properties: {
    addressPrefix: '192.168.3.0/27'
    nextHopType: 'VirtualAppliance'
    nextHopIpAddress: '192.168.1.4'
  }
  dependsOn: [
    routeTables_rt_spoke1_security_name_resource
  ]
}

resource virtualNetworks_vnet_hub_security_lab_name_AzureFirewallSubnet 'Microsoft.Network/virtualNetworks/subnets@2025-09-01' = {
  name: '${virtualNetworks_vnet_hub_security_lab_name}/AzureFirewallSubnet'
  properties: {
    addressPrefixes: [
      '192.168.1.0/26'
    ]
    delegations: []
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
    defaultOutboundAccess: false
  }
  dependsOn: [
    virtualNetworks_vnet_hub_security_lab_name_resource
  ]
}

resource virtualNetworks_vnet_hub_security_lab_name_resource 'Microsoft.Network/virtualNetworks@2025-09-01' = {
  name: virtualNetworks_vnet_hub_security_lab_name
  location: 'uksouth'
  tags: {
    Project: 'Hub-Spoke-Security'
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        '192.168.1.0/24'
      ]
    }
    encryption: {
      enabled: false
      enforcement: 'AllowUnencrypted'
    }
    privateEndpointVNetPolicies: 'Disabled'
    subnets: [
      {
        name: 'AzureFirewallSubnet'
        id: virtualNetworks_vnet_hub_security_lab_name_AzureFirewallSubnet.id
        properties: {
          addressPrefixes: [
            '192.168.1.0/26'
          ]
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
          defaultOutboundAccess: false
        }
      }
    ]
    virtualNetworkPeerings: [
      {
        name: 'hub-to-spoke1'
        id: virtualNetworks_vnet_hub_security_lab_name_hub_to_spoke1.id
        properties: {
          peeringState: 'Connected'
          peeringSyncLevel: 'FullyInSync'
          remoteVirtualNetwork: {
            id: virtualNetworks_vnet_spoke1_security_lab_name_resource.id
          }
          allowVirtualNetworkAccess: true
          allowForwardedTraffic: true
          allowGatewayTransit: false
          useRemoteGateways: false
          doNotVerifyRemoteGateways: false
          peerCompleteVnets: true
          enableOnlyIPv6Peering: false
          remoteAddressSpace: {
            addressPrefixes: [
              '192.168.2.0/24'
            ]
          }
          remoteVirtualNetworkAddressSpace: {
            addressPrefixes: [
              '192.168.2.0/24'
            ]
          }
        }
      }
      {
        name: 'hub-to-spoke2'
        id: virtualNetworks_vnet_hub_security_lab_name_hub_to_spoke2.id
        properties: {
          peeringState: 'Connected'
          peeringSyncLevel: 'FullyInSync'
          remoteVirtualNetwork: {
            id: virtualNetworks_vnet_spoke2_security_lab_name_resource.id
          }
          allowVirtualNetworkAccess: true
          allowForwardedTraffic: true
          allowGatewayTransit: false
          useRemoteGateways: false
          doNotVerifyRemoteGateways: false
          peerCompleteVnets: true
          enableOnlyIPv6Peering: false
          remoteAddressSpace: {
            addressPrefixes: [
              '192.168.3.0/24'
            ]
          }
          remoteVirtualNetworkAddressSpace: {
            addressPrefixes: [
              '192.168.3.0/24'
            ]
          }
        }
      }
    ]
    enableDdosProtection: false
  }
}

resource virtualNetworks_vnet_hub_security_lab_name_hub_to_spoke1 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2025-09-01' = {
  name: '${virtualNetworks_vnet_hub_security_lab_name}/hub-to-spoke1'
  properties: {
    peeringState: 'Connected'
    peeringSyncLevel: 'FullyInSync'
    remoteVirtualNetwork: {
      id: virtualNetworks_vnet_spoke1_security_lab_name_resource.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
    doNotVerifyRemoteGateways: false
    peerCompleteVnets: true
    enableOnlyIPv6Peering: false
    remoteAddressSpace: {
      addressPrefixes: [
        '192.168.2.0/24'
      ]
    }
    remoteVirtualNetworkAddressSpace: {
      addressPrefixes: [
        '192.168.2.0/24'
      ]
    }
  }
  dependsOn: [
    virtualNetworks_vnet_hub_security_lab_name_resource
  ]
}

resource virtualNetworks_vnet_hub_security_lab_name_hub_to_spoke2 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2025-09-01' = {
  name: '${virtualNetworks_vnet_hub_security_lab_name}/hub-to-spoke2'
  properties: {
    peeringState: 'Connected'
    peeringSyncLevel: 'FullyInSync'
    remoteVirtualNetwork: {
      id: virtualNetworks_vnet_spoke2_security_lab_name_resource.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
    doNotVerifyRemoteGateways: false
    peerCompleteVnets: true
    enableOnlyIPv6Peering: false
    remoteAddressSpace: {
      addressPrefixes: [
        '192.168.3.0/24'
      ]
    }
    remoteVirtualNetworkAddressSpace: {
      addressPrefixes: [
        '192.168.3.0/24'
      ]
    }
  }
  dependsOn: [
    virtualNetworks_vnet_hub_security_lab_name_resource
  ]
}

resource virtualNetworks_vnet_spoke1_security_lab_name_spoke1_to_hub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2025-09-01' = {
  name: '${virtualNetworks_vnet_spoke1_security_lab_name}/spoke1-to-hub'
  properties: {
    peeringState: 'Connected'
    peeringSyncLevel: 'FullyInSync'
    remoteVirtualNetwork: {
      id: virtualNetworks_vnet_hub_security_lab_name_resource.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
    doNotVerifyRemoteGateways: false
    peerCompleteVnets: true
    enableOnlyIPv6Peering: false
    remoteAddressSpace: {
      addressPrefixes: [
        '192.168.1.0/24'
      ]
    }
    remoteVirtualNetworkAddressSpace: {
      addressPrefixes: [
        '192.168.1.0/24'
      ]
    }
  }
  dependsOn: [
    virtualNetworks_vnet_spoke1_security_lab_name_resource
  ]
}

resource virtualNetworks_vnet_spoke2_security_lab_name_spoke2_to_hub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2025-09-01' = {
  name: '${virtualNetworks_vnet_spoke2_security_lab_name}/spoke2-to-hub'
  properties: {
    peeringState: 'Connected'
    peeringSyncLevel: 'FullyInSync'
    remoteVirtualNetwork: {
      id: virtualNetworks_vnet_hub_security_lab_name_resource.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
    doNotVerifyRemoteGateways: false
    peerCompleteVnets: true
    enableOnlyIPv6Peering: false
    remoteAddressSpace: {
      addressPrefixes: [
        '192.168.1.0/24'
      ]
    }
    remoteVirtualNetworkAddressSpace: {
      addressPrefixes: [
        '192.168.1.0/24'
      ]
    }
  }
  dependsOn: [
    virtualNetworks_vnet_spoke2_security_lab_name_resource
  ]
}

resource azureFirewalls_fw_hub_security_lab_name_resource 'Microsoft.Network/azureFirewalls@2025-09-01' = {
  name: azureFirewalls_fw_hub_security_lab_name
  location: 'uksouth'
  tags: {
    Project: 'Hub-Spoke-Security'
  }
  properties: {
    sku: {
      name: 'AZFW_VNet'
      tier: 'Standard'
    }
    threatIntelMode: 'Alert'
    additionalProperties: {}
    ipConfigurations: [
      {
        name: 'pip-hub-firewall'
        id: '${azureFirewalls_fw_hub_security_lab_name_resource.id}/azureFirewallIpConfigurations/pip-hub-firewall'
        properties: {
          publicIPAddress: {
            id: publicIPAddresses_pip_hub_firewall_name_resource.id
          }
          subnet: {
            id: virtualNetworks_vnet_hub_security_lab_name_AzureFirewallSubnet.id
          }
        }
      }
    ]
    networkRuleCollections: []
    applicationRuleCollections: []
    natRuleCollections: []
    firewallPolicy: {
      id: firewallPolicies_fw_policy_hub_security_name_resource.id
    }
  }
}

resource virtualNetworks_vnet_spoke1_security_lab_name_resource 'Microsoft.Network/virtualNetworks@2025-09-01' = {
  name: virtualNetworks_vnet_spoke1_security_lab_name
  location: 'uksouth'
  tags: {
    Project: 'Hub-Spoke-Security'
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        '192.168.2.0/24'
      ]
    }
    encryption: {
      enabled: false
      enforcement: 'AllowUnencrypted'
    }
    privateEndpointVNetPolicies: 'Disabled'
    subnets: [
      {
        name: 'snet-spoke1-app'
        id: virtualNetworks_vnet_spoke1_security_lab_name_snet_spoke1_app.id
        properties: {
          addressPrefixes: [
            '192.168.2.0/27'
          ]
          networkSecurityGroup: {
            id: networkSecurityGroups_nsg_spoke1_app_name_resource.id
          }
          routeTable: {
            id: routeTables_rt_spoke1_security_name_resource.id
          }
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
          defaultOutboundAccess: false
        }
      }
    ]
    virtualNetworkPeerings: [
      {
        name: 'spoke1-to-hub'
        id: virtualNetworks_vnet_spoke1_security_lab_name_spoke1_to_hub.id
        properties: {
          peeringState: 'Connected'
          peeringSyncLevel: 'FullyInSync'
          remoteVirtualNetwork: {
            id: virtualNetworks_vnet_hub_security_lab_name_resource.id
          }
          allowVirtualNetworkAccess: true
          allowForwardedTraffic: true
          allowGatewayTransit: false
          useRemoteGateways: false
          doNotVerifyRemoteGateways: false
          peerCompleteVnets: true
          enableOnlyIPv6Peering: false
          remoteAddressSpace: {
            addressPrefixes: [
              '192.168.1.0/24'
            ]
          }
          remoteVirtualNetworkAddressSpace: {
            addressPrefixes: [
              '192.168.1.0/24'
            ]
          }
        }
      }
    ]
    enableDdosProtection: false
  }
}

resource virtualNetworks_vnet_spoke2_security_lab_name_resource 'Microsoft.Network/virtualNetworks@2025-09-01' = {
  name: virtualNetworks_vnet_spoke2_security_lab_name
  location: 'uksouth'
  tags: {
    Project: 'Hub-Spoke-Security'
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        '192.168.3.0/24'
      ]
    }
    encryption: {
      enabled: false
      enforcement: 'AllowUnencrypted'
    }
    privateEndpointVNetPolicies: 'Disabled'
    subnets: [
      {
        name: 'snet-spoke2-db'
        id: virtualNetworks_vnet_spoke2_security_lab_name_snet_spoke2_db.id
        properties: {
          addressPrefixes: [
            '192.168.3.0/27'
          ]
          networkSecurityGroup: {
            id: networkSecurityGroups_nsg_spoke2_db_name_resource.id
          }
          routeTable: {
            id: routeTables_rt_spoke2_security_name_resource.id
          }
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
          defaultOutboundAccess: false
        }
      }
    ]
    virtualNetworkPeerings: [
      {
        name: 'spoke2-to-hub'
        id: virtualNetworks_vnet_spoke2_security_lab_name_spoke2_to_hub.id
        properties: {
          peeringState: 'Connected'
          peeringSyncLevel: 'FullyInSync'
          remoteVirtualNetwork: {
            id: virtualNetworks_vnet_hub_security_lab_name_resource.id
          }
          allowVirtualNetworkAccess: true
          allowForwardedTraffic: true
          allowGatewayTransit: false
          useRemoteGateways: false
          doNotVerifyRemoteGateways: false
          peerCompleteVnets: true
          enableOnlyIPv6Peering: false
          remoteAddressSpace: {
            addressPrefixes: [
              '192.168.1.0/24'
            ]
          }
          remoteVirtualNetworkAddressSpace: {
            addressPrefixes: [
              '192.168.1.0/24'
            ]
          }
        }
      }
    ]
    enableDdosProtection: false
  }
}

resource virtualNetworks_vnet_spoke1_security_lab_name_snet_spoke1_app 'Microsoft.Network/virtualNetworks/subnets@2025-09-01' = {
  name: '${virtualNetworks_vnet_spoke1_security_lab_name}/snet-spoke1-app'
  properties: {
    addressPrefixes: [
      '192.168.2.0/27'
    ]
    networkSecurityGroup: {
      id: networkSecurityGroups_nsg_spoke1_app_name_resource.id
    }
    routeTable: {
      id: routeTables_rt_spoke1_security_name_resource.id
    }
    delegations: []
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
    defaultOutboundAccess: false
  }
  dependsOn: [
    virtualNetworks_vnet_spoke1_security_lab_name_resource
  ]
}

resource virtualNetworks_vnet_spoke2_security_lab_name_snet_spoke2_db 'Microsoft.Network/virtualNetworks/subnets@2025-09-01' = {
  name: '${virtualNetworks_vnet_spoke2_security_lab_name}/snet-spoke2-db'
  properties: {
    addressPrefixes: [
      '192.168.3.0/27'
    ]
    networkSecurityGroup: {
      id: networkSecurityGroups_nsg_spoke2_db_name_resource.id
    }
    routeTable: {
      id: routeTables_rt_spoke2_security_name_resource.id
    }
    delegations: []
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
    defaultOutboundAccess: false
  }
  dependsOn: [
    virtualNetworks_vnet_spoke2_security_lab_name_resource
  ]
}
