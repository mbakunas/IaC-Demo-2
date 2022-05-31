targetScope = 'resourceGroup'

param subnet_Name string
param subnet_NsgId string

resource nsg 'Microsoft.Network/virtualNetworks/subnets@2021-08-01' = {
  name: subnet_Name
  properties: {
    networkSecurityGroup: {
      id: subnet_NsgId
    }
  }
}
