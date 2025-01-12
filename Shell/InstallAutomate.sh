#!/bin/bash

mkdir /tmp/ltagent
cd /tmp/ltagent
curl -sS https://itsynergy.hostedrmm.com/LabTech/Deployment.aspx?InstallerToken=7c45f5ac6008488da3ad184fd1577cfb > ltagent.zip
unzip ltagent.zip
sudo installer -pkg LTSvc.mpkg -target /
sleep 20
rm *
cd .
rmdir /tmp/ltagent