$printerName = "PRT_KYOCERA_BENEDEN"
$newPort = "10.0.10.246"

Get-WmiObject -Query "Select * From Win32_Printer Where Name = '$printerName'" |
    ForEach-Object {
        $_.PortName = "TCPPort:$newPort"
        $_.Put()
    }