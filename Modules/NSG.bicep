targetScope = 'resourceGroup'

param nsg_Location string
param nsg_Subnets array
param nsg_VNet string


resource vnet 'Microsoft.Network/virtualNetworks@2021-08-01' existing = {
  name: nsg_VNet
}

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2019-11-01' = [for (subnet, i) in nsg_Subnets: if (contains(subnet, 'nsgName')) {
  name: contains(subnet, 'nsgName') ? subnet.nsgName : 'Foo${i}'
  location: nsg_Location
  tags: resourceGroup().tags
  properties: {
    securityRules: []
  }
}]

resource nsg 'Microsoft.Network/virtualNetworks/subnets@2021-08-01' = [for (subnet, i) in nsg_Subnets: if (contains(subnet, 'nsgName')) {
  name: contains(subnet, 'nsgName') ? subnet.name : 'Bar${i}'
  parent: vnet
  properties: {
    addressPrefix: subnet.addressSpace
    networkSecurityGroup: {
      id: networkSecurityGroup[i].id
    }
  }
}]

//output nsgId array = [for (subnet, i) in nsg_Subnets: contains(subnet, 'nsgName') ? networkSecurityGroup[i].id : null ]
