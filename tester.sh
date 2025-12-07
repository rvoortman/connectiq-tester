#!/bin/bash

#retrieve parameters
DEVICE_ID=${1:-fenix7}
CERTIFICATE_PATH=$2

set -e

#info displays a message passed as a parameter of read it from stdin
function info {
	#retrieve message from the parameter
	if [[ -n $1 ]]
	then
		message="$1"
		echo -e "$message"
	#or read the message directly
	else
		while read -r message
		do
			info "$message"
		done
	fi
}

#generate temporary certificate if required
if [[ -z $CERTIFICATE_PATH ]]
then
	info "Generating temporary certificate..."
	openssl genrsa -out /tmp/key.pem 4096 && openssl pkcs8 -topk8 -inform PEM -outform DER -in /tmp/key.pem -out /tmp/key.der -nocrypt
	CERTIFICATE_PATH=/tmp/key.der
fi

#compile application
info "Compiling application..."

monkeyc -f monkey.jungle -d "$DEVICE_ID" -o bin/app.prg -y "$CERTIFICATE_PATH" -t

#check if the compiler produced a resulting program file
if [[ ! -f bin/app.prg ]]; then
	info "Compilation failed!"
	exit 1
fi

info "Build success!"

