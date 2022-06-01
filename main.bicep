targetScope = 'subscription'


param primaryRegion string = 'eastus2'
param resourceGroupRegion string = deployment().location
param vnets array


var vnets_temp = [for vnet in vnets: {
  subnets: vnet.subnets
}]

output subnets_flattened array = vnets_temp

resource resourceGroups 'Microsoft.Resources/resourceGroups@2021-04-01' = [for vnet in vnets: {
  name: vnet.resourceGroupName
  location: resourceGroupRegion
  tags: vnet.resourceGroupTags
}]

module VNets 'Modules/VNet.bicep' = [for (vnet, i) in vnets: {
  name: '${deployment().name}-VNet${i}'
  scope: resourceGroups[i]
  params: {
    subnets: vnet.subnets
    vnet_AddressSpace: vnet.addressSpace
    vnet_Location: primaryRegion
    vnet_Name: vnet.name
  }
}]

module nsgs 'Modules/NSG.bicep' = [for (vnet, i) in vnets: {
  scope: resourceGroups[i]
  name: '${deployment().name}-NSGs-for-VNet${i}'
  dependsOn: VNets
  params: {
    nsg_Location: primaryRegion
    nsg_Subnets: vnet.subnets
    nsg_VNet: vnet.name
  }
}]

// route tables



// peer VNets
