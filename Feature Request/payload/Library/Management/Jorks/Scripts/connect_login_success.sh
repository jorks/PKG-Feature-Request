#!/bin/bash

/usr/bin/osascript -e 'display notification with title "Jamf Connect: Success" subtitle "User authenticated. This is an example script which can run on authentication."'

theDate=$(date)

defaults write /Library/Management/Jorks/Data/com.jorks.jamfconnect.plist LastAuthenticationJamfConnect "Success - ${theDate}"

exit 0