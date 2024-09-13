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
}
