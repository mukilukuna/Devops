#!/bin/sh

#Get current Mac serial number
serial_Number=$(system_profiler SPHardwareDataType | awk '/Serial/ {print $4}')

# Rename computer and host name
scutil --set ComputerName CIRMB"$serial_Number"
scutil --set LocalHostName CIRMB"$serial_Number"
scutil --set HostName CIRMB"$serial_Number"

exit 0