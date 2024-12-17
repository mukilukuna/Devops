#This script serves to automaticly extend disk space
#The script checks if the machine has a temporary storage volume
#The script adjusts Pagefile size based on the size of the disk where pagefile exists

#Remember to reboot the machine after running the script

#Refer to D if temp storage exists there, otherwise refer to Windows volume
#For windows Volume a pagefile is created as azure does not auto define it
switch ((Get-WmiObject Win32_LogicalDisk | Where-Object VolumeName -EQ 'Temporary Storage').deviceID) {
    "D:" { $logicaldisk = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='D:'"; Break }
    default {
        $logicaldisk = Get-WmiObject Win32_LogicalDisk | Where-Object VolumeName -EQ 'Windows'; 
        $computersys = Get-WmiObject Win32_ComputerSystem -EnableAllPrivileges;
        $computersys.AutomaticManagedPagefile = $False;
        $computersys.Put() | Out-Null; 
        Break
    }
}
#Define Pagefile and Disk size
$pagefileset = Get-WmiObject win32_pagefilesetting | Where-Object { $_.caption -like "$($LogicalDisks.DeviceID)*" }
$checkPagedisksize = ((Get-WmiObject Win32_LogicalDisk | Where-Object { $_.caption -like "$($logicaldisk.DeviceID)" }) | Select-Object @{name = "GB"; Expression = { ($_.size / 1GB) } } | Select-Object -ExpandProperty GB | Out-String).Split('.,')[0].Trim()
#Change Pagefile Size
switch ($checkPagedisksize) {
    { $_ -In 60..129 } {
        $pagefileset.InitialSize = 16384; $pagefileset.MaximumSize = 16384
        Break
    }
    { $_ -In 130..269 } {
        $pagefileset.InitialSize = 32768; $pagefileset.MaximumSize = 32768
        Break
    }
    { $_ -In 270..569 } {
        $pagefileset.InitialSize = 65536; $pagefileset.MaximumSize = 65536
        Break
    }
    { $_ -In 570..620 } {
        $pagefileset.InitialSize = 131072; $pagefileset.MaximumSize = 131072
        Break
    }
    default {
        $computersys = Get-WmiObject Win32_ComputerSystem -EnableAllPrivileges;
        $computersys.AutomaticManagedPagefile = $False;
        $computersys.Put() | Out-Null; 
        Break
    }
}
#save Settings
$pagefileset.Put() | Out-Null