targetScope = 'resourceGroup'

param nsg_Name string
param nsg_Location string

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2019-11-01' = if (nsg_Name != 'none') {
  name: nsg_Name
  location: nsg_Location
  tags: resourceGroup().tags
  properties: {
    securityRules: []
  }
}

output nsgId string = nsg_Name != 'none' ? networkSecurityGroup.id : 'none' 
