#!/bin/sh
# Dit script creëert een nieuwe gebruikersaccount op macOS.

# Configuratie variabelen: Pas de accountnaam en wachtwoord aan naar behoefte.
accountname="its_local"          # De gebruikersnaam voor de nieuwe account.
password=""      # Het wachtwoord voor de nieuwe account.

# Gebruikersaccount aanmaken.
dscl . -create /Users/$accountname

# De standaard shell instellen als /bin/bash.
dscl . -create /Users/$accountname UserShell /bin/bash

# Volledige naam van de gebruiker instellen.
dscl . -create /Users/$accountname RealName "ITS Local Account"

# Een unieke ID toewijzen aan de gebruikersaccount.
dscl . -create /Users/$accountname UniqueID "2001"

# Primaire groep-ID instellen. Gebruik 20 voor admin accounts en 80 voor standaard accounts.
dscl . -create /Users/$accountname PrimaryGroupID 20

# De thuismap van de gebruiker instellen.
dscl . -create /Users/$accountname NFSHomeDirectory /Users/$accountname

# Wachtwoord voor de gebruikersaccount instellen.
dscl . -passwd /Users/$accountname $password

# De gebruiker toevoegen aan de admin groep.
dscl . -append /Groups/admin GroupMembership $accountname

# (Optioneel) De gebruikersprofielfoto instellen.
dscl . -create /Users/$accountname Picture "/profilepic.png"

# (Optioneel) Een wachtwoordhint toevoegen voor de gebruiker.
dscl . -create /Users/$accountname Hint "Provide Password hint"

# (Optioneel) De gebruiker verbergen in het macOS login venster.
dscl . -create /Users/$accountname IsHidden 1

# Einde van het script.
