// --------------------------------------------------------------------------------
// Creates a Cosmos 429 Alert
// --------------------------------------------------------------------------------
param actionGroupName string = 'CosmosAlertGroup1'
@maxLength(12)
param actionGroupShortName string = 'cosalrtgrp1'
param notificationEmail string = ''

param cosmosAccountName string
param alertName string = 'Cosmos429Alert'
param alertDescription string = 'Alert on too many 429 errors'
param alertSeverity int = 3
param evaluationFrequency string = 'PT5M'
param windowSize string = 'PT1H'
param threshold int = 25

// --------------------------------------------------------------------------------
// Variables
// --------------------------------------------------------------------------------
var emailReceivers = (notificationEmail == '') ? [] : [
  {
    name: 'emailme_-EmailAction-'
    emailAddress: notificationEmail
    useCommonAlertSchema: true
  }
]
var armRole_Owner_Guid = '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
var armRoleReceivers = [
  {
    name: 'ArmRole'
    roleId: armRole_Owner_Guid
    useCommonAlertSchema: true
  }
]

// --------------------------------------------------------------------------------
// Find resources
// --------------------------------------------------------------------------------
resource cosmosAccountResource 'Microsoft.DocumentDB/databaseAccounts@2022-05-15' existing = { name: cosmosAccountName }
var cosmosDbResourceId = cosmosAccountResource.id

// --------------------------------------------------------------------------------
// Create alert group
// --------------------------------------------------------------------------------
// group: Defined Owner
resource actionGroup_resource 'microsoft.insights/actionGroups@2023-01-01' = {
  name: actionGroupName
  location: 'Global'
  properties: {
    groupShortName: actionGroupShortName
    enabled: true
    emailReceivers: emailReceivers
    armRoleReceivers: armRoleReceivers
  }
}

// --------------------------------------------------------------------------------
// Create alerts
// --------------------------------------------------------------------------------
resource cosmos429Alert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: alertName
  location: 'global'
  properties: {
    description: alertDescription
    severity: alertSeverity
    enabled: true
    scopes: [
      cosmosDbResourceId
    ]
    evaluationFrequency: evaluationFrequency
    windowSize: windowSize
    criteria: {
      allOf: [
        {
          threshold: threshold
          name: '429ErrorCount'
          metricNamespace: 'Microsoft.DocumentDB/databaseAccounts'
          metricName: 'TotalRequests'
          dimensions: [
            {
              name: 'StatusCode'
              operator: 'Include'
              values: [
                '429'
              ]
            }
          ]
          operator: 'GreaterThan'
          timeAggregation: 'Count'
          skipMetricValidation: false
          criterionType: 'StaticThresholdCriterion'
        }
      ]
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
    }
    autoMitigate: false
    actions: [
      {
        actionGroupId: actionGroup_resource.id
      }
    ]
  }
}
