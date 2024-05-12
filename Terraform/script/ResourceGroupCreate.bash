#!/bin/bash

# Variable for customer code
customerCode="<customercode>" # Replace <customercode> with your actual customer code

# Azure location where the resource groups will be created
location="westeurope"

# Declare an array of resource group names
declare -a resourceGroups=("${customerCode}euazu-net" "${customerCode}euazu-host" "${customerCode}euazu-stor")

# Loop through the resource group names
for rgName in "${resourceGroups[@]}"; do
    # Check if the Resource Group already exists
    exists=$(az group exists --name $rgName)
    
    if [ "$exists" = "false" ]; then
        # Resource Group does not exist, create it
        az group create --name $rgName --location $location
        echo "Resource Group '$rgName' created in $location."
    else
        echo "Resource Group '$rgName' already exists."
    fi
done
