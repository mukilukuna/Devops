# Script: Set_PWAHelper.ps1
# Purpose: Set PWAHelper
$Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\"
$msedge = $path + "msedge.exe"
$ExtendPropertyPath = get-itemproperty -Path $msedge -name Path | Select-Object -ExpandProperty Path

if ($msedge) {
    $proxy = "msedge_proxy.exe"
    $pwahelper = "pwahelper.exe"
    if (!(test-path $Path$proxy)) {
        New-Item -path $Path$proxy
        Set-ItemProperty -Path $Path$proxy -name '(default)' -Value "$ExtendPropertyPath\$proxy"
        new-ItemProperty -Path $Path$proxy -name 'Path' -Value $ExtendPropertyPath
    }
    if (!(test-path $Path$pwahelper)) {
        New-Item -path $Path$pwahelper
        Set-ItemProperty -Path $Path$pwahelper -name '(default)' -Value "$ExtendPropertyPath\$pwahelper"
        new-ItemProperty -Path $Path$pwahelper -name 'Path' -Value $ExtendPropertyPath 
    }
    else {
        Write-Host "keys already set"
        exit
    }
}
else {
    write-host "edge is not installed"
    exit
}