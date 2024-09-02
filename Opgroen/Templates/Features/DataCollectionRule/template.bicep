targetScope = 'resourceGroup'

param dcrName string

param location string = 'westeurope'

param logAnalyticsWorkspaceResourceId string

param dataFlows array = [
  {
    streams: [
      'Microsoft-Perf'
      'Microsoft-Event'
      'Microsoft-Syslog'
      'Microsoft-ConfigurationChange'
      'Microsoft-ConfigurationChangeV2'
      'Microsoft-ConfigurationData'
    ]
    destinations: [
      'law-destination'
    ]
  }
]

param performanceCounters array = [
  {
    streams: [
      'Microsoft-Perf'
    ]
    samplingFrequencyInSeconds: 60
    counterSpecifiers: [
      '\\Processor Information(_Total)\\% Processor Time'
      '\\Processor Information(_Total)\\% Privileged Time'
      '\\Processor Information(_Total)\\% User Time'
      '\\Processor Information(_Total)\\Processor Frequency'
      '\\System\\Processes'
      '\\Process(_Total)\\Thread Count'
      '\\Process(_Total)\\Handle Count'
      '\\System\\System Up Time'
      '\\System\\Context Switches/sec'
      '\\System\\Processor Queue Length'
      '\\Memory\\% Committed Bytes In Use'
      '\\Memory\\Available Bytes'
      '\\Memory\\Committed Bytes'
      '\\Memory\\Cache Bytes'
      '\\Memory\\Pool Paged Bytes'
      '\\Memory\\Pool Nonpaged Bytes'
      '\\Memory\\Pages/sec'
      '\\Memory\\Page Faults/sec'
      '\\Process(_Total)\\Working Set'
      '\\Process(_Total)\\Working Set - Private'
      '\\LogicalDisk(_Total)\\% Disk Time'
      '\\LogicalDisk(_Total)\\% Disk Read Time'
      '\\LogicalDisk(_Total)\\% Disk Write Time'
      '\\LogicalDisk(_Total)\\% Idle Time'
      '\\LogicalDisk(_Total)\\Disk Bytes/sec'
      '\\LogicalDisk(_Total)\\Disk Read Bytes/sec'
      '\\LogicalDisk(_Total)\\Disk Write Bytes/sec'
      '\\LogicalDisk(_Total)\\Disk Transfers/sec'
      '\\LogicalDisk(_Total)\\Disk Reads/sec'
      '\\LogicalDisk(_Total)\\Disk Writes/sec'
      '\\LogicalDisk(_Total)\\Avg. Disk sec/Transfer'
      '\\LogicalDisk(_Total)\\Avg. Disk sec/Read'
      '\\LogicalDisk(_Total)\\Avg. Disk sec/Write'
      '\\LogicalDisk(_Total)\\Avg. Disk Queue Length'
      '\\LogicalDisk(_Total)\\Avg. Disk Read Queue Length'
      '\\LogicalDisk(_Total)\\Avg. Disk Write Queue Length'
      '\\LogicalDisk(_Total)\\% Free Space'
      '\\LogicalDisk(_Total)\\Free Megabytes'
      '\\Network Interface(*)\\Bytes Total/sec'
      '\\Network Interface(*)\\Bytes Sent/sec'
      '\\Network Interface(*)\\Bytes Received/sec'
      '\\Network Interface(*)\\Packets/sec'
      '\\Network Interface(*)\\Packets Sent/sec'
      '\\Network Interface(*)\\Packets Received/sec'
      '\\Network Interface(*)\\Packets Outbound Errors'
      '\\Network Interface(*)\\Packets Received Errors'
      'Processor(*)\\% Processor Time'
      'Processor(*)\\% Idle Time'
      'Processor(*)\\% User Time'
      'Processor(*)\\% Nice Time'
      'Processor(*)\\% Privileged Time'
      'Processor(*)\\% IO Wait Time'
      'Processor(*)\\% Interrupt Time'
      'Processor(*)\\% DPC Time'
      'Memory(*)\\Available MBytes Memory'
      'Memory(*)\\% Available Memory'
      'Memory(*)\\Used Memory MBytes'
      'Memory(*)\\% Used Memory'
      'Memory(*)\\Pages/sec'
      'Memory(*)\\Page Reads/sec'
      'Memory(*)\\Page Writes/sec'
      'Memory(*)\\Available MBytes Swap'
      'Memory(*)\\% Available Swap Space'
      'Memory(*)\\Used MBytes Swap Space'
      'Memory(*)\\% Used Swap Space'
      'Process(*)\\Pct User Time'
      'Process(*)\\Pct Privileged Time'
      'Process(*)\\Used Memory'
      'Process(*)\\Virtual Shared Memory'
      'Logical Disk(*)\\% Free Inodes'
      'Logical Disk(*)\\% Used Inodes'
      'Logical Disk(*)\\Free Megabytes'
      'Logical Disk(*)\\% Free Space'
      'Logical Disk(*)\\% Used Space'
      'Logical Disk(*)\\Logical Disk Bytes/sec'
      'Logical Disk(*)\\Disk Read Bytes/sec'
      'Logical Disk(*)\\Disk Write Bytes/sec'
      'Logical Disk(*)\\Disk Transfers/sec'
      'Logical Disk(*)\\Disk Reads/sec'
      'Logical Disk(*)\\Disk Writes/sec'
      'Network(*)\\Total Bytes Transmitted'
      'Network(*)\\Total Bytes Received'
      'Network(*)\\Total Bytes'
      'Network(*)\\Total Packets Transmitted'
      'Network(*)\\Total Packets Received'
      'Network(*)\\Total Rx Errors'
      'Network(*)\\Total Tx Errors'
      'Network(*)\\Total Collisions'
      'System(*)\\Uptime'
      'System(*)\\Load1'
      'System(*)\\Load5'
      'System(*)\\Load15'
      'System(*)\\Users'
      'System(*)\\Unique Users'
      'System(*)\\CPUs'
    ]
    name: 'perfCounterDataSource'
  }
  {
    streams: [
      'Microsoft-Perf'
    ]
    samplingFrequencyInSeconds: 60
    counterSpecifiers: [
      '\\VmInsights\\DetailedMetrics'
    ]
    name: 'VmInsightsDataSource'
  }
]

param windowsEventLogs array = [
  {
    streams: [
      'Microsoft-Event'
    ]
    xPathQueries: [
      'Application!*[System[(Level=1 or Level=2)]]'
      'System!*[System[(Level=1 or Level=2)]]'
      'System!*[System[Provider[@Name=\'Service Control Manager\'] and (EventID=7036)]]'
      'Microsoft-Windows-Windows Defender/Operational!*[System[(EventID=1151 or EventID=2001 or EventID=2003 or EventID=2006 or EventID=5001 or EventID=5010 or EventID=5012)]]'
      'Microsoft-FSLogix-Apps/Operational!*[System[(Level=2)]]'
    ]
    name: 'eventLogsDataSource'
  }
]

param syslog array = [
  {
    streams: [
      'Microsoft-Syslog'
    ]
    facilityNames: [
      'alert'
      'audit'
      'auth'
      'authpriv'
      'clock'
      'cron'
      'daemon'
      'ftp'
      'kern'
      'local0'
      'local1'
      'local2'
      'local3'
      'local4'
      'local5'
      'local6'
      'local7'
      'lpr'
      'mail'
      'news'
      'nopri'
      'ntp'
      'syslog'
      'user'
      'uucp'
    ]
    logLevels: [
      'Debug'
      'Info'
      'Notice'
      'Warning'
      'Error'
      'Critical'
      'Alert'
      'Emergency'
    ]
    name: 'sysLogsDataSource'
  }
]

@description('')
param destinations object = {
  logAnalytics: [
    {
      workspaceResourceId: logAnalyticsWorkspaceResourceId
      name: 'law-destination'
    }
  ]
}

param extensions array = [
  {
    name: 'CTDataSource-Windows'
    extensionName: 'ChangeTracking-Windows'
    extensionSettings: {
      enableFiles: true
      enableSoftware: true
      enableRegistry: true
      enableServices: true
      enableInventory: true
      registrySettings: {
        registryCollectionFrequency: 3000
        registryInfo: [
          {
            name: 'Registry_1'
            groupTag: 'Recommended'
            enabled: true
            recurse: true
            description: ''
            keyName: 'HKEY_LOCAL_MACHINE\\Software\\Microsoft\\Windows\\CurrentVersion\\Group Policy\\Scripts\\Startup'
            valueName: ''
          }
          {
            name: 'Registry_2'
            groupTag: 'Recommended'
            enabled: true
            recurse: true
            description: ''
            keyName: 'HKEY_LOCAL_MACHINE\\Software\\Microsoft\\Windows\\CurrentVersion\\Group Policy\\Scripts\\Shutdown'
            valueName: ''
          }
          {
            name: 'Registry_3'
            groupTag: 'Recommended'
            enabled: true
            recurse: true
            description: ''
            keyName: 'HKEY_LOCAL_MACHINE\\SOFTWARE\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Run'
            valueName: ''
          }
          {
            name: 'Registry_4'
            groupTag: 'Recommended'
            enabled: true
            recurse: true
            description: ''
            keyName: 'HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Active Setup\\Installed Components'
            valueName: ''
          }
          {
            name: 'Registry_5'
            groupTag: 'Recommended'
            enabled: true
            recurse: true
            description: ''
            keyName: 'HKEY_LOCAL_MACHINE\\Software\\Classes\\Directory\\ShellEx\\ContextMenuHandlers'
            valueName: ''
          }
          {
            name: 'Registry_6'
            groupTag: 'Recommended'
            enabled: true
            recurse: true
            description: ''
            keyName: 'HKEY_LOCAL_MACHINE\\Software\\Classes\\Directory\\Background\\ShellEx\\ContextMenuHandlers'
            valueName: ''
          }
          {
            name: 'Registry_7'
            groupTag: 'Recommended'
            enabled: true
            recurse: true
            description: ''
            keyName: 'HKEY_LOCAL_MACHINE\\Software\\Classes\\Directory\\Shellex\\CopyHookHandlers'
            valueName: ''
          }
          {
            name: 'Registry_8'
            groupTag: 'Recommended'
            enabled: true
            recurse: true
            description: ''
            keyName: 'HKEY_LOCAL_MACHINE\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\ShellIconOverlayIdentifiers'
            valueName: ''
          }
          {
            name: 'Registry_9'
            groupTag: 'Recommended'
            enabled: true
            recurse: true
            description: ''
            keyName: 'HKEY_LOCAL_MACHINE\\Software\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Explorer\\ShellIconOverlayIdentifiers'
            valueName: ''
          }
          {
            name: 'Registry_10'
            groupTag: 'Recommended'
            enabled: true
            recurse: true
            description: ''
            keyName: 'HKEY_LOCAL_MACHINE\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Browser Helper Objects'
            valueName: ''
          }
          {
            name: 'Registry_11'
            groupTag: 'Recommended'
            enabled: true
            recurse: true
            description: ''
            keyName: 'HKEY_LOCAL_MACHINE\\Software\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Browser Helper Objects'
            valueName: ''
          }
          {
            name: 'Registry_12'
            groupTag: 'Recommended'
            enabled: true
            recurse: true
            description: ''
            keyName: 'HKEY_LOCAL_MACHINE\\Software\\Microsoft\\Internet Explorer\\Extensions'
            valueName: ''
          }
          {
            name: 'Registry_13'
            groupTag: 'Recommended'
            enabled: true
            recurse: true
            description: ''
            keyName: 'HKEY_LOCAL_MACHINE\\Software\\Wow6432Node\\Microsoft\\Internet Explorer\\Extensions'
            valueName: ''
          }
          {
            name: 'Registry_14'
            groupTag: 'Recommended'
            enabled: true
            recurse: true
            description: ''
            keyName: 'HKEY_LOCAL_MACHINE\\Software\\Microsoft\\Windows NT\\CurrentVersion\\Drivers32'
            valueName: ''
          }
          {
            name: 'Registry_15'
            groupTag: 'Recommended'
            enabled: true
            recurse: true
            description: ''
            keyName: 'HKEY_LOCAL_MACHINE\\Software\\Wow6432Node\\Microsoft\\Windows NT\\CurrentVersion\\Drivers32'
            valueName: ''
          }
          {
            name: 'Registry_16'
            groupTag: 'Recommended'
            enabled: true
            recurse: true
            description: ''
            keyName: 'HKEY_LOCAL_MACHINE\\System\\CurrentControlSet\\Control\\Session Manager\\KnownDlls'
            valueName: ''
          }
          {
            name: 'Registry_17'
            groupTag: 'Recommended'
            enabled: true
            recurse: true
            description: ''
            keyName: 'HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Winlogon\\Notify'
            valueName: ''
          }
        ]
      }
      fileSettings: {
        fileCollectionFrequency: 2700
      }
      softwareSettings: {
        softwareCollectionFrequency: 1800
      }
      inventorySettings: {
        inventoryCollectionFrequency: 36000
      }
      servicesSettings: {
        serviceCollectionFrequency: 1800
      }
    }
    streams: [
      'Microsoft-ConfigurationChange'
      'Microsoft-ConfigurationChangeV2'
      'Microsoft-ConfigurationData'
    ]
  }
  {
    name: 'CTDataSource-Linux'
    extensionName: 'ChangeTracking-Linux'
    extensionSettings: {
      enableFiles: true
      enableSoftware: true
      enableRegistry: true
      enableServices: true
      enableInventory: true
      fileSettings: {
        fileCollectionFrequency: 900
        fileInfo: [
          {
            name: 'ChangeTrackingLinuxPath_default'
            enabled: true
            destinationPath: ' /etc/.*.conf'
            useSudo: true
            recurse: true
            maxContentsReturnable: 5000000
            pathType: 'File'
            type: 'File'
            links: 'Follow'
            maxOutputSize: 500000
            groupTag: 'Recommended'
          }
        ]
      }
      softwareSettings: {
        softwareCollectionFrequency: 300
      }
      inventorySettings: {
        inventoryCollectionFrequency: 36000
      }
      servicesSettings: {
        serviceCollectionFrequency: 300
      }
    }
    streams: [
      'Microsoft-ConfigurationChange'
      'Microsoft-ConfigurationChangeV2'
      'Microsoft-ConfigurationData'
    ]
  }
]

param tags object = {}

resource dcr 'Microsoft.Insights/dataCollectionRules@2023-03-11' = {
  name: dcrName
  location: location
  tags: tags
  kind: null
  properties: {
    dataFlows: dataFlows
    dataSources: {
      performanceCounters: performanceCounters
      windowsEventLogs: windowsEventLogs
      syslog: syslog
      extensions: extensions
    }
    destinations: destinations
  }
}

@description('The name of the Azure resource')
output resourceName string = dcr.name
@description('The resource-id of the Azure resource')
output resourceId string = dcr.id
