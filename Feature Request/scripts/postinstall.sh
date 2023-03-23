#!/bin/sh
## postinstall

pathToScript=$0
pathToPackage=$1
targetLocation=$2
targetVolume=$3


echo "Hello from postinstall" >> /Library/Management/Jorks/Logs/TestInstall.log



exit 0		## Success
exit 1		## Failure
