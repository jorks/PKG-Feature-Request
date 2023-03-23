#!/bin/bash
# set -x

#	Boilerplate for Jamf API Bearer Auth: jamfUAPITokenAuth.sh
#	Functions for safe token-based auth using the Jamf Pro API
#	To token auth use: --header "Authorization: Bearer $token"
#
#	You can also call these functions in your scrip logic:
#	testToken - returns 200 if the token is still valid
#	expireToken - expires the current token and unsets the variable
#
#	DO NOT RUN API SCRIPTS FROM JAMF PRO POLICIES - VERY INSECURE
#
#	James Corcoran 2021 - Melbourne Australia - https://jorks.net
#	Feedback: https://github.com/jorks
#	Script version 0.1
#   Written and tested on macOS

################ USER DEFINED VARIABLES START ###########################

JAMF_URL=${1}
JAMF_USERNAME=${2}
JAMF_PASSWORD=${3}
PACKAGE_NAME=${4}

################ AUTHENTICATION FUNCTIONS ###############################

function get_token () {
	local encodedCredentials
	local tokenResponse
	# Encode credentials 
	encodedCredentials=$( printf "%s" "${JAMF_USERNAME}:${JAMF_PASSWORD}" | /usr/bin/iconv -t ISO-8859-1 | /usr/bin/base64 -i - )
	# Get a token
	tokenResponse=$( /usr/bin/curl --silent --request POST \
		--url ${JAMF_URL}/api/v1/auth/token \
		--header 'Accept: application/json' \
		--header 'Content-Type: application/json' \
		--header "Authorization: Basic ${encodedCredentials}" )
	
	echo "Get Auth Bearer result: $?"
	token=$( printf "%s" "${tokenResponse}" | awk -F\" '/token/{print $4}' )
}

function test_token () {
	# Returns HTTP response code - 200 is success
	/usr/bin/curl --silent --head --request GET \
		--url ${JAMF_URL}/api/v1/auth \
		--header "Authorization: Bearer ${token}" \
		--write-out "%{http_code}" \
		--output /dev/null
}

function expire_token () {
	/usr/bin/curl --silent --request POST \
		--url ${JAMF_URL}/api/v1/auth/invalidate-token \
		--header 'Accept: application/json' \
		--header "Authorization: Bearer ${token}"
	
	unset token
}

# Distroy the token when the script exits
trap expire_token EXIT

# Get a bearer token and test it
get_token 
if [[ $(test_token) -ne 200 ]]; then exit; fi

################ MAIN SCRIPT START ###############################

# You can run the main script here if you want a single file script

# Example GET request
TEST_RESPONSE=$(
	curl --silent --request GET \
			--url ${JAMF_URL}/api/v1/jamf-pro-version \
			--header 'Accept: application/json' \
			--header "Authorization: Bearer ${token}"
)

echo "Jamf Pro Version: ${TEST_RESPONSE}"


# Create a package record using the Jamf API.
if [[ -n "${JAMF_URL}" ]] && [[ -n "${JAMF_USERNAME}" ]] && [[ -n "${JAMF_PASSWORD}" ]] && [[ -n "${PACKAGE_NAME}" ]]; then
	PKG_RESPONSE=$(
		curl --silent --request POST \
				--url ${JAMF_URL}/JSSResource/packages/id/id \
				--header "Content-Type: text/xml" \
				--header "Authorization: Bearer ${token}" \
				--data "<package><name>${PACKAGE_NAME}</name><filename>${PACKAGE_NAME}.pkg</filename></package>"
	)

	echo "Post a new Package returned: ${PKG_RESPONSE}"
else
	echo "Error: Missing some details."
fi
