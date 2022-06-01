targetScope = 'subscription'


param primaryRegion string = 'eastus2'
param resourceGroupRegion string = deployment().location
param vnets array

//
// deploy VNets with subnets
//


// VNets
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



// NSGs

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

// module subnet 'Modules/Subnet.bicep' = [for (subnet, i) in vnets[0].subnets: if(contains(subnet, 'nsgName')) {
//   scope: resourceGroup[0]
//   name: '${deployment().name}-UpdateSubnet${i}'
//   params: {
//     subnet_Name: subnet.name
//     subnet_AddressSpace: subnet.addressSpace
//     subnet_NsgId: nsgs[i].outputs.nsgId
//     subnet_VnetName: vnets[0].name
//   }
// }]

// redeploy subnets with route tables



// peer VNets
