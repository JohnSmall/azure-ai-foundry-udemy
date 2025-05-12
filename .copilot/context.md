# Project Context for GitHub Copilot

This is a set of examples from a Udemy course on Microsoft Azure AI foundry
It was cloned from the GitHub reposity that goes along with the course

## Goal
To be able to run the code for each lesson
We will need to create Bicep files to set up the components in Azure AI Foundary as they do not exist in the current code

## Tools
- Microsoft AI Foundry
- Azure OpenAI (text-embedding-ada-002, gpt-35-turbo)
- Python, VSCode, GitHub Copilot

## Bicep Templates
These are used to set up components in Azure that are required for the examples to run
The directory `bicep-templates' holds the templates.
It contains ARM files exported from Azure into json files. These json files are only for reference. They are used as a basis for creating Bicep templates
There will be a master template for the Azure AI hub, and then Bicep templates for each lesson

