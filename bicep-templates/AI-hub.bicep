@description('Specifies the location for all resources.')
param location string = resourceGroup().location

@description('Specifies the name of the Azure AI hub workspace.')
param workspaceName string = 'ai-hub-${uniqueString(resourceGroup().id)}'

@description('Specifies the SKU name for the workspace.')
param skuName string = 'Basic'

@description('Specifies the SKU tier for the workspace.')
param skuTier string = 'Basic'

@description('Specifies the name of the storage account.')
param storageAccountName string = 'aihub${uniqueString(resourceGroup().id)}'

@description('Specifies the name of the key vault.')
param keyVaultName string = 'kv-aihub-${uniqueString(resourceGroup().id)}'

@description('Specifies the name of the application insights component.')
param appInsightsName string = 'ai-insights-${uniqueString(resourceGroup().id)}'

@description('Specifies whether public network access is allowed for the workspace.')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Enabled'

@description('Specifies the isolation mode for the managed network.')
@allowed([
  'AllowInternetOutbound'
  'AllowOnlyApprovedOutbound'
])
param isolationMode string = 'AllowInternetOutbound'

// Create a storage account
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    encryption: {
      services: {
        blob: {
          enabled: true
        }
        file: {
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
  }
}

// Create a key vault
resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
    tenantId: subscription().tenantId
    accessPolicies: []
    sku: {
      name: 'standard'
      family: 'A'
    }
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
  }
}

// Create an Application Insights component
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    DisableIpMasking: false
    DisableLocalAuth: false
    Flow_Type: 'Bluefield'
    ForceCustomerStorageForProfiler: false
    Request_Source: 'rest' // Changed from RequestSource to Request_Source
    RetentionInDays: 90
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

// Create the AI Hub workspace
resource aiHubWorkspace 'Microsoft.MachineLearningServices/workspaces@2024-07-01-preview' = {
  name: workspaceName
  location: location
  kind: 'hub'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    friendlyName: workspaceName
    description: 'Azure AI Hub workspace for development and deployment of AI solutions'
    storageAccount: storageAccount.id
    keyVault: keyVault.id
    applicationInsights: appInsights.id
    publicNetworkAccess: publicNetworkAccess
    managedNetwork: {
      isolationMode: isolationMode
      outboundRules: {
        // Default rule for Azure Storage
        rule1: {
          category: 'Required'
          status: 'Active'
          type: 'ServiceTag'
          destination: {
            serviceTag: 'Storage'
          }
        }
        // Default rule for Key Vault
        rule2: {
          category: 'Required'
          status: 'Active'
          type: 'ServiceTag'
          destination: {
            serviceTag: 'AzureKeyVault'
          }
        }
        // Default rule for Azure AD
        rule3: {
          category: 'Required'
          status: 'Active'
          type: 'ServiceTag'
          destination: {
            serviceTag: 'AzureActiveDirectory'
          }
        }
      }
    }
  }
}

// Define the SKU as a separate resource property
var skuInfo = {
  name: skuName
  tier: skuTier
}

// Outputs
output aiHubWorkspaceId string = aiHubWorkspace.id
output aiHubWorkspaceName string = aiHubWorkspace.name
output skuInfo object = skuInfo
output storageAccountId string = storageAccount.id
output keyVaultId string = keyVault.id
output appInsightsId string = appInsights.id
