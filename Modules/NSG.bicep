targetScope = 'resourceGroup'

param nsg_Name string
param nsg_Location string

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2019-11-01' = {
  name: nsg_Name
  location: nsg_Location
  tags: resourceGroup().tags
  properties: {
    securityRules: []
  }
}

output nsgId string = networkSecurityGroup.id
