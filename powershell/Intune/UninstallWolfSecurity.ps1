# PowerShell script to uninstall HP Wolf Security and related components silently

# Uninstall HP Wolf Security
wmic product where name="HP Wolf Security" call uninstall /nointeractive

# Uninstall HP Wolf Security - Console
wmic product where name="HP Wolf Security - Console" call uninstall /nointeractive

# Uninstall HP Security Update Service
wmic product where name="HP Security Update Service" call uninstall /nointeractive
