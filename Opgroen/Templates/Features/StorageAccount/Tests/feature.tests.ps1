#Requires -Version 7

param (
	[string]$FeaturePath,
	[string]$ParameterFilePath,
	[string]$TemplateFileName = 'template.json'
)

$script:ParameterFilePath = Get-ChildItem -Path $ParameterFilePath
$script:TemplateFileName = $TemplateFileName

Describe "Template: $(Split-Path $($(Get-Item $PSScriptRoot).Parent.FullName) -Leaf)" -Tags Unit {

	Context "Template File Syntax" {

		It "JSON template file ($TemplateFileName) exists" {
			if (-not (Get-ChildItem $($(Get-Item $PSScriptRoot).Parent.FullName) $TemplateFileName)) {
				Write-Host "   [-] Template file ($TemplateFileName) does not exist."
				exit
			}
			(Join-Path -Path $($(Get-Item $PSScriptRoot).Parent.FullName) -ChildPath $TemplateFileName) | Should -Exist
		}
	}

	Context "Parameter File Syntax" {

		It "Parameter file (<ParameterFilePath>)  does contain all expected properties" {

			$ExpectedProperties = '$schema',
			'contentVersion',
			'parameters'| Sort-Object
			$templateFileProperties = (Get-Content $ParameterFilePath `
				| ConvertFrom-Json -ErrorAction SilentlyContinue) `
			| Get-Member -MemberType NoteProperty `
			| Sort-Object -Property Name `
			| ForEach-Object Name
			$templateFileProperties | Should -Be $ExpectedProperties
		}
	}

	Context "Template and Parameter Compatibility" {

		It "Count of required parameters in template file ($TemplateFileName) is equal or less than count of all parameters in parameters file (<ParameterFilePath>)" {

			$requiredParametersInTemplateFile = (Get-Content (Join-Path -Path $($(Get-Item $PSScriptRoot).Parent.FullName) -ChildPath $TemplateFileName) `
				| ConvertFrom-Json -ErrorAction SilentlyContinue).Parameters.PSObject.Properties `
			| Where-Object -FilterScript { -not ($_.Value.PSObject.Properties.Name -eq "defaultValue") } `
			| Sort-Object -Property Name `
			| ForEach-Object Name
			$allParametersInParametersFile = (Get-Content $ParameterFilePath `
				| ConvertFrom-Json -ErrorAction SilentlyContinue).Parameters.PSObject.Properties `
			| Sort-Object -Property Name `
			| ForEach-Object Name
			if ($requiredParametersInTemplateFile.Count -gt $allParametersInParametersFile.Count) {
				Write-Host "   [-] Required parameters are: $requiredParametersInTemplateFile"
				$requiredParametersInTemplateFile.Count | Should -Not -BeGreaterThan $allParametersInParametersFile.Count
			}
		}

		It "All parameters in parameters file (<ParameterFilePath>) exist in template file ($TemplateFileName)" {

			$allParametersInTemplateFile = (Get-Content (Join-Path -Path $($(Get-Item $PSScriptRoot).Parent.FullName) -ChildPath $TemplateFileName) `
				| ConvertFrom-Json -ErrorAction SilentlyContinue).Parameters.PSObject.Properties `
			| Sort-Object -Property Name `
			| ForEach-Object Name
			$allParametersInParametersFile = (Get-Content $ParameterFilePath `
				| ConvertFrom-Json -ErrorAction SilentlyContinue).Parameters.PSObject.Properties `
			| Sort-Object -Property Name `
			| ForEach-Object Name
			$result = @($allParametersInParametersFile | Where-Object { $allParametersInTemplateFile -notcontains $_ })
			if ($result) {
				Write-Host "   [-] Following parameter does not exist: $result"
			}
			@($allParametersInParametersFile | Where-Object { $allParametersInTemplateFile -notcontains $_ }).Count | Should -Be 0
		}

		It "All required parameters in template file ($TemplateFileName) existing in parameters file (<ParameterFilePath>)" {

			$requiredParametersInTemplateFile = (Get-Content (Join-Path -Path $($(Get-Item $PSScriptRoot).Parent.FullName) -ChildPath $TemplateFileName) `
				| ConvertFrom-Json -ErrorAction SilentlyContinue).Parameters.PSObject.Properties `
			| Where-Object -FilterScript { -not ($_.Value.PSObject.Properties.Name -eq "defaultValue") } `
			| Sort-Object -Property Name `
			| ForEach-Object Name
			$allParametersInParametersFile = (Get-Content $ParameterFilePath `
				| ConvertFrom-Json -ErrorAction SilentlyContinue).Parameters.PSObject.Properties `
			| Sort-Object -Property Name `
			| ForEach-Object Name
			$result = $requiredParametersInTemplateFile | Where-Object { $allParametersInParametersFile -notcontains $_ }
			if ($result.Count -gt 0) {
				Write-Host "   [-] Required parameters: $result"
			}
			@($requiredParametersInTemplateFile | Where-Object { $allParametersInParametersFile -notcontains $_ }).Count | Should -Be 0
		}
	}

	Context "Parameter security check" {

		It "Parameter encryptionBlob in template file (<ParameterFilePath>) should be true" {

			$parametersInParametersFile = (Get-Content $ParameterFilePath |
				ConvertFrom-Json -ErrorAction SilentlyContinue).Parameters.PSObject.Properties |
			Where-Object { $_.name -eq "encryptionBlob" }

			if ($parametersInParametersFile) {
				$parametersInParametersFile.Value.value | Should -Be $true
			}
		}

		It "Parameter encryptionFile in template file (<ParameterFilePath>) should be true" {

			$parametersInParametersFile = (Get-Content $ParameterFilePath |
				ConvertFrom-Json -ErrorAction SilentlyContinue).Parameters.PSObject.Properties |
			Where-Object { $_.name -eq "encryptionFile" }

			if ($parametersInParametersFile) {
				$parametersInParametersFile.Value.value | Should -Be $true
			}
		}

		It "Parameter supportsHttpsTrafficOnly in template file (<ParameterFilePath>) should be true" {

			$parametersInParametersFile = (Get-Content $ParameterFilePath |
				ConvertFrom-Json -ErrorAction SilentlyContinue).Parameters.PSObject.Properties |
			Where-Object { $_.name -eq "supportsHttpsTrafficOnly" }

			if ($parametersInParametersFile) {
				$parametersInParametersFile.Value.value | Should -Be $true
			}
		}

		It "Parameter publicNetworkAccess in template file (<ParameterFilePath>) should be disabled" {

			$parametersInParametersFile = (Get-Content $ParameterFilePath |
				ConvertFrom-Json -ErrorAction SilentlyContinue).Parameters.PSObject.Properties |
			Where-Object { $_.name -eq "publicNetworkAccess" }

			if ($parametersInParametersFile) {
				$parametersInParametersFile.Value.value | Should -Be "Disabled"
			}
		}

		It "Parameter deleteRetentionPolicy in template file (<ParameterFilePath>) should be disabled" {

			$parametersInParametersFile = (Get-Content $ParameterFilePath |
				ConvertFrom-Json -ErrorAction SilentlyContinue).Parameters.PSObject.Properties |
			Where-Object { $_.name -eq "deleteRetentionPolicy" }

			if ($parametersInParametersFile) {
				$parametersInParametersFile.Value.value | Should -Be $true
			}
		}
	}
}
