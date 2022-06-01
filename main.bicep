targetScope = 'subscription'


param primaryRegion string = 'eastus2'
param resourceGroupRegion string = deployment().location
param vnets array

//
// deploy VNets with subnets
//


// VNets
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = [for vnet in vnets: {
  name: vnet.resourceGroupName
  location: resourceGroupRegion
  tags: vnet.resourceGroupTags
}]

module hubVNet 'Modules/VNet.bicep' = [for (vnet, i) in vnets: {
  name: '${deployment().name}-${vnet.name}'
  scope: resourceGroup[i]
  params: {
    subnets: vnet.subnets
    vnet_AddressSpace: vnet.addressSpace
    vnet_Location: primaryRegion
    vnet_Name: vnet.name
  }
}]



// redeploy subnets with NSGs

// module hubNsg 'Modules/NSG.bicep' = [for (subnet, i) in vnets[0].subnets: {
//   scope: resourceGroup[0]
//   name: '${deployment().name}-NSG${i}'
//   params: {
//     nsg_Location: primaryRegion
//     nsg_Name: contains(subnet, 'nsgName') ? subnet.nsgName : 'none' 
//   }
// }]

// module subnet 'Modules/Subnet.bicep' = [for (subnet, i) in vnets[0].subnets: if(contains(subnet, 'nsgName')) {
//   scope: resourceGroup[0]
//   name: '${deployment().name}-UpdateSubnet${i}'
//   params: {
//     subnet_Name: subnet.name
//     subnet_AddressSpace: subnet.addressSpace
//     subnet_NsgId: hubNsg[i].outputs.nsgId
//     subnet_VnetName: vnets[0].name
//   }
// }]

// redeploy subnets with route tables



// peer VNets
