<#
.SYNOPSIS
    Short description
.DESCRIPTION
    Long description
.EXAMPLE
    PS .\New-RunAsAccount.ps1 -ResourceGroup christian-rsg -AutomationAccountName debesteaa -ApplicationDisplayName debesteaa-runas -SubscriptionId 372ff4eb-841d-4efa-af11-f057c9460c0d -SelfSignedCertPassword (New-Guid | ConvertTo-SecureString -AsPlainText)
    This creates: a self signed certificate, a service principal, an automation certificate and connection asset which can be utilized as a RunAs-Cred
.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    General notes
#>

#Requires -RunAsAdministrator
Param (
    [Parameter(Mandatory = $true)][String] $ResourceGroup,
    [Parameter(Mandatory = $true)][String] $AutomationAccountName,
    [Parameter(Mandatory = $true)][String] $ApplicationDisplayName,
    [Parameter(Mandatory = $true)][String] $SubscriptionId,
    [Parameter(Mandatory = $true)][SecureString] $SelfSignedCertPassword,
    [Parameter(Mandatory = $false)][string] $EnvironmentName = "AzureCloud",
    [Parameter(Mandatory = $false)][int] $SelfSignedCertNoOfMonthsUntilExpired = 12
)


function New-InSparkSelfSignedCertificate ([string] $certificateName, [securestring] $SelfSignedCertPassword, [string] $certPath, [string] $certPathCer, [string] $selfSignedCertNoOfMonthsUntilExpired ) {
    Write-Host "  Begin Function New-InSparkSelfSignedCertificate"
    $Cert = New-SelfSignedCertificate -DnsName $certificateName -CertStoreLocation cert:\LocalMachine\My -KeyExportPolicy Exportable -Provider "Microsoft Enhanced RSA and AES Cryptographic Provider" -NotAfter (Get-Date).AddMonths($selfSignedCertNoOfMonthsUntilExpired) -HashAlgorithm SHA256
    Export-PfxCertificate -Cert ("Cert:\localmachine\my\" + $Cert.Thumbprint) -FilePath $certPath -Password $SelfSignedCertPassword -Force | Write-Verbose
    Export-Certificate -Cert ("Cert:\localmachine\my\" + $Cert.Thumbprint) -FilePath $certPathCer -Type CERT | Write-Verbose
    Write-Host "  End Function New-InSparkSelfSignedCertificate"
}

function New-InSparkAzureADServicePrincipal ([System.Security.Cryptography.X509Certificates.X509Certificate2] $PfxCert, [string] $applicationDisplayName) {
    Write-Host "  Begin Function New-InSparkAzureADServicePrincipal"
    $keyValue = [System.Convert]::ToBase64String($PfxCert.GetRawCertData())
    $keyId = (New-Guid).Guid

    $startDate = Get-Date
    $endDate = (Get-Date $PfxCert.GetExpirationDateString()).AddDays(-1)

    # Create an Azure AD application, AD App Credential, AD ServicePrincipal
    try {
        $Application = Get-AzADApplication -DisplayNameStartWith $ApplicationDisplayName
        if (!$Application) {
            $Application = New-AzADApplication -DisplayName $ApplicationDisplayName -HomePage ("http://" + $applicationDisplayName) -IdentifierUris ("http://" + $keyId)
            New-AzADAppCredential -ApplicationId $Application.ApplicationId -CertValue $keyValue -StartDate $startDate -EndDate $endDate
        }
        $ServicePrincipal = Get-AzADServicePrincipal | Where-Object -FilterScript { $_.ApplicationId -eq $Application.ApplicationId }
        if (!$ServicePrincipal) {
            $ServicePrincipal = New-AzADServicePrincipal -ApplicationId $Application.ApplicationId
            Get-AzADServicePrincipal -ObjectId $ServicePrincipal.Id
        }
    } catch {
        Write-Host $_.Exception
    }

    # Sleep here for a few seconds to allow the service principal application to become active (ordinarily takes a few seconds)
    Start-Sleep -Seconds 15
    $Role = Get-AzRoleAssignment -ServicePrincipalName $ServicePrincipal.ServicePrincipalNames[0] -RoleDefinitionName Contributor -Scope "/subscriptions/$SubscriptionId"
    if (!$Role) {
        $NewRole = New-AzRoleAssignment -RoleDefinitionName Contributor -ApplicationId $Application.ApplicationId -Scope "/subscriptions/$SubscriptionId"
        $Retries = 0;
        While ($null -eq $NewRole -and $Retries -le 6) {
            Start-Sleep -Seconds 10
            New-AzRoleAssignment -RoleDefinitionName Contributor -ApplicationId $Application.ApplicationId -Scope "/subscriptions/$SubscriptionId"
            $NewRole = Get-AzRoleAssignment -ServicePrincipalName $Application.ApplicationId -ErrorAction SilentlyContinue
            $Retries++;
        }
    }
    Write-Host "  End Function New-InSparkAzureADServicePrincipal"
    return $Application.ApplicationId.ToString();
}

function New-InSparkAutomationCertificateAsset ([string] $resourceGroup, [string] $automationAccountName, [string] $certifcateAssetName, [string] $certPath, [securestring]$certPassword, [Boolean] $Exportable) {
    Write-Host "  Begin Function New-InSparkAutomationCertificateAsset"
    Remove-AzAutomationCertificate -ResourceGroupName $resourceGroup -AutomationAccountName $automationAccountName -Name $certifcateAssetName -ErrorAction SilentlyContinue
    New-AzAutomationCertificate -ResourceGroupName $resourceGroup -AutomationAccountName $automationAccountName -Path $certPath -Name $certifcateAssetName -Password $certPassword -Exportable:$Exportable  | Write-Verbose
    Write-Host "  End Function New-InSparkAutomationCertificateAsset"
}

function New-InSparkAutomationConnectionAsset ([string] $resourceGroup, [string] $automationAccountName, [string] $connectionAssetName, [string] $connectionTypeName, [System.Collections.Hashtable] $connectionFieldValues ) {
    Write-Host "  Begin Function New-InSparkAutomationConnectionAsset"
    Remove-AzAutomationConnection -ResourceGroupName $resourceGroup -AutomationAccountName $automationAccountName -Name $connectionAssetName -Force -ErrorAction SilentlyContinue
    New-AzAutomationConnection -ResourceGroupName $ResourceGroup -AutomationAccountName $automationAccountName -Name $connectionAssetName -ConnectionTypeName $connectionTypeName -ConnectionFieldValues $connectionFieldValues
    Write-Host "  End Function New-InSparkAutomationConnectionAsset"
}



Write-Host "Import modules"
try {
    Import-Module Az.Resources
} catch {
    Write-Host $_.Exception
}

Write-Host "Select subscription"
try {
    $Subscription = Get-AzSubscription -SubscriptionId $SubscriptionId
    $TenantId = ($Subscription | Select-Object TenantId -First 1).TenantId
    Write-Host "$Subscription -  $TenantId"
} catch {
    Write-Host $_.Exception
}

Write-Host "Checking for existing RunAs connection"
$ExistingConnection = Get-AzAutomationConnection -ResourceGroupName $ResourceGroup -AutomationAccountName $AutomationAccountName -Name "AzureRunAsConnection" -ErrorAction SilentlyContinue
if ($ExistingConnection) {
    Write-Host "Existing RunAs connection found, exiting."
    exit
}

# Create a Run As account by using a service principal
$CertifcateAssetName = "AzureRunAsCertificate"
$ConnectionAssetName = "AzureRunAsConnection"
$ConnectionTypeName = "AzureServicePrincipal"


Write-Host "Start creating self signed certificate"
try {
    $CertificateName = $AutomationAccountName + $CertifcateAssetName
    $PfxCertPathForRunAsAccount = Join-Path $env:TEMP ($CertificateName + ".pfx")
    $PfxCertPasswordForRunAsAccount = $SelfSignedCertPassword
    $CerCertPathForRunAsAccount = Join-Path $env:TEMP ($CertificateName + ".cer")
    New-InSparkSelfSignedCertificate $CertificateName $PfxCertPasswordForRunAsAccount $PfxCertPathForRunAsAccount $CerCertPathForRunAsAccount $SelfSignedCertNoOfMonthsUntilExpired
} catch {
    Write-Host $_.Exception
}


Write-Host "Create a service principal"
try {
    $PfxCert = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList @($PfxCertPathForRunAsAccount, $PfxCertPasswordForRunAsAccount)
    $ApplicationId = New-InSparkAzureADServicePrincipal $PfxCert $ApplicationDisplayName
} catch {
    Write-Host $_.Exception
}


Write-Host "Create the Automation certificate asset"
Select-AzSubscription -TenantId $TenantId -Subscription $Subscription
New-InSparkAutomationCertificateAsset $ResourceGroup $AutomationAccountName $CertifcateAssetName $PfxCertPathForRunAsAccount $PfxCertPasswordForRunAsAccount $true

Write-Host "Populate the ConnectionFieldValues"
try {
    $Thumbprint = $PfxCert.Thumbprint
    $ConnectionFieldValues = @{"ApplicationId" = $ApplicationId; "TenantId" = $TenantId; "CertificateThumbprint" = $Thumbprint; "SubscriptionId" = $SubscriptionId }
} catch {
    Write-Host $_.Exception
}

Write-Host "Create an Automation connection asset named AzureRunAsConnection in the Automation account. This connection uses the service principal."
New-InSparkAutomationConnectionAsset $ResourceGroup $AutomationAccountName $ConnectionAssetName $ConnectionTypeName $ConnectionFieldValues


Write-Output "Script is finished"
