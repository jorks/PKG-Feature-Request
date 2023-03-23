#!/bin/bash

/usr/bin/osascript -e 'display alert "Authentication Failed" message "This is an example of a script that can be run if an authentication fails.  In this case, authenticating using Jamf Connect with the jamfse.io domain was not successful.  If you need help, refer to the Preconfigured Evaluation Guide for user names and passwords."'

theDate=$(date)

defaults write /Library/Management/Jorks/Data/com.jorks.jamfconnect.plist LastAuthenticationJamfConnect "Fail - ${theDate}"

exit 0