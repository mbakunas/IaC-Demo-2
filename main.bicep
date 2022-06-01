targetScope = 'subscription'


param primaryRegion string = 'eastus2'
param resourceGroupRegion string = deployment().location
param vnets array

// hub VNet
// param hubVnet_ResourceGroupName string
// param hubVnet_ResourceGroupTags object
// param hubVnet_Name string
// param hubVnet_AddressSpace string
// param hubVnet_SubnetList array





//
// deploy VNets with subnets
//

// var hubVNet_Subnets = [for subnet in vnets[0]: {
//   name: subnet.name
//   addressSpace: subnet.addressSpace
// }]

// hub VNet
resource hubResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: vnets[0].resourceGroupName
  location: resourceGroupRegion
  tags: vnets[0].resourceGroupTags
}

module hubVNet 'Modules/VNet.bicep' = {
  name: '${deployment().name}-hubVNet'
  scope: hubResourceGroup
  params: {
    subnets: vnets[0].subnets
    vnet_AddressSpace: vnets[0].addressSpace
    vnet_Location: primaryRegion
    vnet_Name: vnets[0].name
  }
}


// redeploy subnets with NSGs

module hubNsg 'Modules/NSG.bicep' = [for (subnet, i) in vnets[0].subnets: {
  scope: hubResourceGroup
  name: '${deployment().name}-NSG${i}'
  params: {
    nsg_Location: primaryRegion
    nsg_Name: contains(subnet, 'nsgName') ? subnet.nsgName : 'none' 
  }
}]

module subnet 'Modules/Subnet.bicep' = [for (subnet, i) in vnets[0].subnets: if(contains(subnet, 'nsgName')) {
  scope: hubResourceGroup
  name: '${deployment().name}-UpdateSubnet${i}'
  params: {
    subnet_Name: subnet.name
    subnet_AddressSpace: subnet.addressSpace
    subnet_NsgId: hubNsg[i].outputs.nsgId
    subnet_VnetName: vnets[0].name
  }
}]

// redeploy subnets with route tables



// peer VNets
