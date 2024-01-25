#!/bin/bash
# Creates an Azure resource group with tags using Azure CLI
#
# This script creates a new Azure resource group with the provided name,
# location, and tags. It takes in parameters for the resource group name,
# location, owner, cost center, application name, description, and repository.
#
# Tags are assigned using the Azure CLI command to create the resource group with tags.

# Parameters
location=$1
resourceGroupName=$2
owner=$3
costCenter=$4
application=$5
description=$6
repo=$7

# Create a tag string
tags="Owner=$owner Costcenter=$costCenter Application=$application Description=$description Repository=$repo"

echo "Creating the resource group"
echo "Location: $location"
echo "Resource group name: $resourceGroupName"

# Create resource group with tags
az group create --name $resourceGroupName --location $location --tags $tags

# Check if the command was successful
if [ $? -eq 0 ]; then
    echo "Resource group created successfully"
else
    echo "Failed to create resource group"
    exit 1
fi
