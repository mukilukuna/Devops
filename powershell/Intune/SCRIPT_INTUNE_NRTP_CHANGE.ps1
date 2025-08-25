$rules = @(
  @{ ns=".privatelink.file.core.windows.net"; dns="10.202.10.5" },
  @{ ns=".file.core.windows.net";              dns="10.202.10.5" }
)

foreach ($r in $rules) {
  $cur = Get-DnsClientNrptRule | Where-Object Namespace -eq $r.ns
  if ($cur) {
    if ($cur.NameServers -ne $r.dns) {
      Set-DnsClientNrptRule -Namespace $r.ns -NameServers $r.dns
    }
  } else {
    Add-DnsClientNrptRule -Namespace $r.ns -NameServers $r.dns -Comment "Managed by script"
  }
}
ipconfig /flushdns
