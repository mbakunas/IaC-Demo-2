targetScope = 'resourceGroup'

// VNet
param vnet_Name string
param vnet_AddressSpace string
param vnet_Location string
param vnet_RouteTableId string

// Subnets
param subnets array
/*
Format the array like this:
  {
    name: 'AzureBastionSubnet'
    addressSpace: '10.0.0.128/26'
  }
  {
    name: 'CorpNet'
    addressSpace: '10.0.1.0/24'
    nsgName: 'CorpNet-10.0.1.0_24'
  }
]
*/

var specialSubnets = [
  'GatewaySubnet'
  'AzureFirewallSubnet'
  'AzureBastionSubnet'
  'RouteServerSubnet'
]


resource virtualNetwork 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: vnet_Name
  location: vnet_Location
  tags: resourceGroup().tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnet_AddressSpace
      ]
    }
    subnets: [for (subnet, i) in subnets: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.addressSpace
        networkSecurityGroup: {
          id: (contains(specialSubnets, subnet.name) ? null : networkSecurityGroup[i].id)
        }
        routeTable: {
          id: (contains(specialSubnets, subnet.name) ? null : vnet_RouteTableId)
        }
      }
    }]
  }
}

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2020-11-01' = [ for i in range(0, length(subnets)): if (subnets[i].nsgName != 'none') {
  //name: (contains(specialSubnets, subnets[i].name) ? 'foo' : subnets[i].nsgName)
  name: subnets[i].nsgName
  location: vnet_Location
  tags: resourceGroup().tags
  properties: {
    securityRules: []
  }
}]
