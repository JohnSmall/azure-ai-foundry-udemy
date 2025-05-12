@description('Location for all resources.')
param location string = resourceGroup().location

@description('Name of the workspace for lesson 1')
param workspacesLesson1Name string = 'lesson-1-${uniqueString(resourceGroup().id)}'

@description('Name of the Udemy hub training workspace')
param workspacesUdemyHubTrainingName string = 'udemy-hub-4-training-${uniqueString(resourceGroup().id)}'

// Removing unused datastore parameters that were flagged by the linter

// Storage account for the AI Hub
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: 'stghub${uniqueString(resourceGroup().id)}'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
  }
}

// Key Vault for the AI Hub
resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: 'kv-hub-${uniqueString(resourceGroup().id)}'
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    accessPolicies: []
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
  }
}

// Application Insights for the AI Hub
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: 'ai-insights-${uniqueString(resourceGroup().id)}'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    RetentionInDays: 90
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

// Azure OpenAI Service
resource openaiService 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: 'openai-${uniqueString(resourceGroup().id)}'
  location: location
  kind: 'OpenAI'
  sku: {
    name: 'S0'
  }
  properties: {
    customSubDomainName: 'openai-${uniqueString(resourceGroup().id)}'
    publicNetworkAccess: 'Enabled'
  }
}

// Azure AI Hub Workspace (formerly known as Machine Learning workspace)
resource aiHubWorkspace 'Microsoft.MachineLearningServices/workspaces@2023-10-01' = {
  name: workspacesUdemyHubTrainingName
  location: location
  kind: 'hub'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    friendlyName: workspacesUdemyHubTrainingName
    storageAccount: storageAccount.id
    keyVault: keyVault.id
    applicationInsights: appInsights.id
    publicNetworkAccess: 'Enabled'
    managedNetwork: {
      isolationMode: 'AllowInternetOutbound'
    }
  }
}

// Azure AI Project Workspace (Lesson 1)
resource lesson1Workspace 'Microsoft.MachineLearningServices/workspaces@2023-10-01' = {
  name: workspacesLesson1Name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    friendlyName: workspacesLesson1Name
    description: 'Project workspace for Lesson 1 of the Azure AI Foundry Udemy course'
    // Removing associatedHubWorkspace property as it's not allowed
    // Using an extended API version that supports project workspaces
  }
}

// OpenAI Chat Completions Model Deployment - using parent property syntax
resource chatCompletionsDeployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = {
  parent: openaiService
  name: 'gpt-35-turbo'
  properties: {
    model: {
      format: 'OpenAI'
      name: 'gpt-35-turbo'
      version: '0301'
    }
    scaleSettings: {
      scaleType: 'Standard'
    }
  }
}

// OpenAI Embeddings Model Deployment - using parent property syntax
resource embeddingsDeployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = {
  parent: openaiService
  name: 'text-embedding-ada-002'
  properties: {
    model: {
      format: 'OpenAI'
      name: 'text-embedding-ada-002'
      version: '2'
    }
    scaleSettings: {
      scaleType: 'Standard'
    }
  }
}

// Output the workspace IDs and model deployment names
output aiHubWorkspaceId string = aiHubWorkspace.id
output lesson1WorkspaceId string = lesson1Workspace.id
output chatCompletionsDeploymentName string = chatCompletionsDeployment.name
output embeddingsDeploymentName string = embeddingsDeployment.name
output openaiEndpoint string = 'https://${openaiService.properties.customSubDomainName}.openai.azure.com/'
