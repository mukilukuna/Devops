# Pad van het geblokkeerde bestand (uit de alert)
$path = "C:\Program Files\notepad++\notepad++.exe"

$sig  = Get-AuthenticodeSignature -FilePath $path
$cert = $sig.SignerCertificate              # leaf cert
$dest = "C:\Temp\Notepad++.cer"
Export-Certificate -Cert $cert -FilePath $dest | Out-Null
$cert.Thumbprint
