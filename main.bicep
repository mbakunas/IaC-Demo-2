targetScope = 'subscription'


param primaryRegion string = 'eastus2'
param resourceGroupRegion string = deployment().location

// hub VNet
param hubVnet_ResourceGroupName string
param hubVnet_ResourceGroupTags object
param hubVnet_Name string
param hubVnet_AddressSpace string
param hubVnet_SubnetList array





//
// deploy VNets with subnets
//

var hubVNet_Subnets = [for subnet in hubVnet_SubnetList: {
  name: subnet.name
  addressSpace: subnet.addressSpace
}]

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

module hubNsg 'Modules/NSG.bicep' = [for (subnet, i) in hubVnet_SubnetList: if(contains(subnet, 'nsgName')) {
  scope: hubResourceGroup
  name: '${deployment().name}-NSG${i}'
  params: {
    nsg_Location: primaryRegion
    nsg_Name: subnet.nsgName
  }
}]

module subnet 'Modules/Subnet.bicep' = [for (subnet, i) in hubVnet_SubnetList: if(contains(subnet, 'nsgName')) {
  scope: hubResourceGroup
  name: '${deployment().name}-UpdateSubnet${i}'
  params: {
    subnet_Name: subnet.name
    subnet_AddressSpace: subnet.addressSpace
    subnet_NsgId: hubNsg[i].outputs.nsgId
  }
}]

// redeploy subnets with route tables



// peer VNets
