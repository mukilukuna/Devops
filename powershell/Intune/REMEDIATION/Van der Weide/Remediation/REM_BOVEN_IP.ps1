$printerName = "PRT_KYOCERA_BOVEN"
$newPort = "10.0.10.247"

Get-WmiObject -Query "Select * From Win32_Printer Where Name = '$printerName'" |
    ForEach-Object {
        $_.PortName = "TCPPort:$newPort"
        $_.Put()
    }