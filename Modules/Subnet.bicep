targetScope = 'resourceGroup'

param subnet_Name string
param subnet_AddressSpace string
param subnet_NsgId string
param subnet_VnetName string

resource vnet 'Microsoft.Network/virtualNetworks@2021-08-01' existing = {
  name: subnet_VnetName
}

resource nsg 'Microsoft.Network/virtualNetworks/subnets@2021-08-01' = {
  name: subnet_Name
  parent: vnet
  properties: {
    addressPrefix: subnet_AddressSpace
    networkSecurityGroup: {
      id: subnet_NsgId
    }
  }
}
