// ------------------------------------------------------------------------------------------------------------------------
// Main Bicep File for Alerts and Alert Groups
// ------------------------------------------------------------------------------------------------------------------------
param orgName string = ''
param envName string = 'DEMO'

param runDateTime string = utcNow()
param location string = resourceGroup().location

// ------------------------------------------------------------------------------------------------------------------------
var deploymentSuffix = '-${runDateTime}'

// --------------------------------------------------------------------------------
module resourceNames 'resourcenames.bicep' = {
  name: 'resourceNames${deploymentSuffix}'
  params: {
    orgName: orgName
    environmentName: toLower(envName)
  }
}

// ------------------------------------------------------------------------------------------------------------------------
module alertsGeneralRegistryModule 'alerts-general.bicep' = {
  name: 'alertsGeneral${deploymentSuffix}'
  params: {
    workspaceName: resourceNames.outputs.logAnalyticsWorkspaceName
    location: location
  }
}
