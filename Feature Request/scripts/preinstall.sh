#!/bin/sh
## preinstall

pathToScript=$0
pathToPackage=$1
targetLocation=$2
targetVolume=$3


echo "Hello from preinstall" >> /Library/Management/Jorks/Logs/TestInstall.log



exit 0		## Success
exit 1		## Failure
