#!/bin/sh

#Get current Mac serial number

serial_Number=$(system_profiler SPHardwareDataType | awk '/Serial/ {print $4}')

# Rename computer and host name
scutil --set ComputerName ITSMB"$serial_Number"
scutil --set LocalHostName ITSPMB"$serial_Number"
scutil --set HostName ITSMB"$serial_Number"

# Recon computer name and user to Jamf Pro
/usr/local/bin/jamf recon

exit 0
