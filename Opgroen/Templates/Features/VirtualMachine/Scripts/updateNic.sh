gateway=$(ip route | grep default | cut -d' ' -f3)

IFS=':' read -r -a dnsservers <<< "$DnsServer"
for index in "${!dnsservers[@]}"
do
  declare dns$index=${dnsservers[index]}
done

IFS=':' read -r -a ipaddresses <<< "$IpAddress"
for index in "${!ipaddresses[@]}"
do
  if [ "$index" == "0" ]; then
    cat >/etc/sysconfig/network-scripts/ifcfg-eth0 <<EOL
DEVICE=eth0
BOOTPROTO=static
ONBOOT=yes
IPADDR=${ipaddresses[index]}
PREFIX=${PrefixLength}
GATEWAY=${gateway}
PEERDNS=yes
DNS1=${dns0}
DNS2=${dns1}
EOL
  else
  cat >/etc/sysconfig/network-scripts/ifcfg-eth0:$index <<EOL
DEVICE=eth0:${index}
BOOTPROTO=static
ONBOOT=yes
IPADDR=${ipaddresses[index]}
PREFIX=${PrefixLength}
GATEWAY=${gateway}
EOL
  fi
done

systemctl restart network
