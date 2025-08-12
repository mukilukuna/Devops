$paths = @(
"HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client",
"HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server",
"HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client",
"HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server"
)
$bad = $false
foreach($p in $paths){
  $en = (Get-ItemProperty -Path $p -Name Enabled -ErrorAction SilentlyContinue).Enabled
  $db = (Get-ItemProperty -Path $p -Name DisabledByDefault -ErrorAction SilentlyContinue).DisabledByDefault
  if($en -ne 0 -or $db -ne 1){ $bad = $true }
}
if($bad){ Write-Output "Legacy TLS enabled"; exit 1 } else { Write-Output "TLS 1.0/1.1 disabled"; exit 0 }
