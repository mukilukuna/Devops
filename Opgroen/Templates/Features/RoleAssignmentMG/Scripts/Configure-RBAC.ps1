param(
    [Parameter(Mandatory = $true)][String]$resourceName,
    [Parameter(Mandatory = $true)][String]$roleName
)

try {
    $displayName = ("$resourceName-$roleName").ToLower()
    $group = Get-AzureRmADGroup -SearchString $displayName
    if (!$group) {
        $group = New-AzureRmADGroup -DisplayName $displayName -MailNickName "None"
    }
    $resource = Get-AzureRmResource -Name $resourceName
    New-AzureRmRoleAssignment -ObjectId $group.Id -Scope $resource.ResourceId -RoleDefinitionName $roleName
} catch {
    Write-Output $_.Exception
}
