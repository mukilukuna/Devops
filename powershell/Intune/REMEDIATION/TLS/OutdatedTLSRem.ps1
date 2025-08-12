# TLS 1.0/1.1 UIT
$legacy = @("TLS 1.0","TLS 1.1")
foreach($v in $legacy){
  foreach($role in "Client","Server"){
    $key = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\$v\$role"
    New-Item $key -Force | Out-Null
    New-ItemProperty -Path $key -Name Enabled -Type DWord -Value 0 -Force | Out-Null
    New-ItemProperty -Path $key -Name DisabledByDefault -Type DWord -Value 1 -Force | Out-Null
  }
}

# TLS 1.2/1.3 AAN
$modern = @("TLS 1.2","TLS 1.3")
foreach($v in $modern){
  foreach($role in "Client","Server"){
    $key = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\$v\$role"
    New-Item $key -Force | Out-Null
    New-ItemProperty -Path $key -Name Enabled -Type DWord -Value 1 -Force | Out-Null
    New-ItemProperty -Path $key -Name DisabledByDefault -Type DWord -Value 0 -Force | Out-Null
  }
}

# .NET sterkere crypto prefereren (soms nodig voor oudere apps)
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319" -Name SchUseStrongCrypto -Type DWord -Value 1 -Force | Out-Null
New-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v4.0.30319" -Name SchUseStrongCrypto -Type DWord -Value 1 -Force | Out-Null
