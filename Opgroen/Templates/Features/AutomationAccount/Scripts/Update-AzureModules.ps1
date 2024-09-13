Param(
  [Parameter(Mandatory=$true)][String] $resourceGroupName,
  [Parameter(Mandatory=$true)][String] $automationAccountName
)

function updateModule($automationModuleName) {

  $url = "https://www.powershellgallery.com/api/v2/Search()?`$filter=IsLatestVersion&searchTerm=%27$automationModuleName%27&targetFramework=%27%27&includePrerelease=false&`$skip=0&`$top=40"
  $searchResult = Invoke-RestMethod -Method Get -Uri $url -UseBasicParsing

  if ($searchResult.Length -and $searchResult.Length -gt 1) { $searchResult = $searchResult | Where-Object -FilterScript { $_.properties.title -eq $automationModuleName } }

  if (!$searchResult) {
    Write-Warning "Could not find module '$automationModuleName' on PowerShell Gallery. This may be a module you imported from a different location"
  } else {
    $galleryModuleName = $searchResult.properties.title
    Write-Verbose -Message "Found module '$galleryModuleName' on PowerShell Gallery"

    $packageDetails = Invoke-RestMethod -Method Get -UseBasicParsing -Uri $searchResult.id
    [System.Version] $galleryModuleVersion = $packageDetails.entry.properties.version
    Write-Verbose -Message "Latest version is $galleryModuleVersion"

    $automationModule = Get-AzureRmAutomationModule -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName -Name $automationModuleName

    if (!$automationModule.Version -or [System.Version]($automationModule.Version) -lt $galleryModuleVersion) {
      Write-Verbose -Message "Current version $($automationModule.Version) is not latest version $galleryModuleVersion, updating"

      $dependencies = $packageDetails.entry.properties.dependencies
      Write-Verbose -Message "Dependencies: $dependencies"

      if($dependencies -and $dependencies.Length -gt 0) {
        $dependencies = $dependencies.Split("|")
        $dependencies | ForEach-Object {
          Write-Verbose -Message "Processing dependency $_"
          if($_ -and $_.Length -gt 0) {
            $parts = $_.Split(":")
            $dependencyName = $parts[0]
            [System.Version] $dependencyVersion = ((($parts[1] -replace '\[', '') -replace '\]', '') -replace ',', '') -replace '\)', ''

            Write-Verbose -Message "Checking for module '$dependencyName' version $dependencyVersion"

            $dependencyModule = Get-AzureRmAutomationModule -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName -Name $dependencyName -ErrorAction SilentlyContinue

            if(!$dependencyModule.Version -or [System.Version]($dependencyModule.Version) -lt $dependencyVersion) {
              Write-Verbose -Message "Module '$dependencyName' is currently at version $($dependencyModule.Version), required version is $dependencyVersion, updating"
              updateModule -automationModuleName $dependencyName
            } else {
              Write-Verbose -Message "Module '$dependencyName' has the correct version, skipping"
            }
          }
        }
      }

      $moduleContentUrl = "https://www.powershellgallery.com/api/v2/package/$galleryModuleName/$galleryModuleVersion"
      do {
          $actualUrl = $moduleContentUrl
          $moduleContentUrl = (Invoke-WebRequest -Uri $moduleContentUrl -MaximumRedirection 0 -UseBasicParsing -ErrorAction Ignore).Headers.Location
      } while (!$moduleContentUrl.Contains(".nupkg"))
      $actualUrl = $moduleContentUrl

      Write-Verbose "Importing $galleryModuleName version $galleryModuleVersion"

      $newAutomationModule = New-AzureRmAutomationModule -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName -Name $automationModuleName -ContentLink $actualUrl
      while (
          (!([string]::IsNullOrEmpty($newAutomationModule))) -and
          $newAutomationModule.ProvisioningState -ne "Created" -and
          $newAutomationModule.ProvisioningState -ne "Succeeded" -and
          $newAutomationModule.ProvisioningState -ne "Failed"
      ) {
          Write-Verbose -Message "Polling for module import completion"
          Start-Sleep -Seconds 10
          $newAutomationModule = $newAutomationModule | Get-AzureRmAutomationModule
      }

      if ($newAutomationModule.ProvisioningState -eq "Failed") {
          Write-Error "Importing $galleryModuleName module failed."
      }
      else {
          Write-Verbose "Importing $galleryModuleName module succeeded."
      }
    } else {
      Write-Verbose -Message "Module '$automationModuleName' is up to date"
    }
  }
}

try {
  $modules = Get-AzureRmAutomationModule -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName | Where-Object -FilterScript { $_.Name -like "Azure*" }
  foreach ($module in $modules) {
    Write-Output "Checking for update of module '$($module.Name)'"
    updateModule -automationModuleName $($module.Name)
  }
} catch {
  Write-Output $_
}
