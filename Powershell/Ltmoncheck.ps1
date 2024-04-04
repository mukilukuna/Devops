$ServiceName = 'LTSvcMon'
$arrService = Get-Service -Name $ServiceName

if ($arrService.Status -eq 'Running') {
        Write-Output "running"
}
