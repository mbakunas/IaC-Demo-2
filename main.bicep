targetScope = 'subscription'


param primaryRegion string = 'eastus2'
param resourceGroupRegion string = deployment().location

// hub VNet
param hubVnet_ResourceGroupName string
param hubVnet_ResourceGroupTags object
param hubVnet_Name string
param hubVnet_AddressSpace string
param hubVnet_SubnetList array



var hubVNet_Subnets = [for subnet in hubVnet_SubnetList: {
  name: subnet.name
  addressSpace: subnet.addressSpace
}]


//
// deploy VNets with subnets
//

// hub VNet
resource hubResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: hubVnet_ResourceGroupName
  location: resourceGroupRegion
  tags: hubVnet_ResourceGroupTags
}

module hubVNet 'Modules/VNet.bicep' = {
  name: '${deployment().name}-hubVNet'
  scope: hubResourceGroup
  params: {
    subnets: hubVNet_Subnets
    vnet_AddressSpace: hubVnet_AddressSpace
    vnet_Location: primaryRegion
    vnet_Name: hubVnet_Name
  }
}


// redeploy subnets with NSGs



// redeploy subnets with route tables



// peer VNets
