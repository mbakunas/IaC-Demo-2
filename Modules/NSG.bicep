targetScope = 'resourceGroup'

param nsg_Location string
param nsg_Subnets array

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2019-11-01' = [for subnet in nsg_Subnets: if (contains(subnet, 'nsgName')) {
  name: subnet.nsgName
  location: nsg_Location
  tags: resourceGroup().tags
  properties: {
    securityRules: []
  }
}]

output nsgId array = [for (subnet, i) in nsg_Subnets: contains(subnet, 'nsgName') ? networkSecurityGroup[i].id : null ]
