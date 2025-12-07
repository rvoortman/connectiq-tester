#!/bin/bash

#retrieve parameters
DEVICE_ID=${1:-fenix7}
CERTIFICATE_PATH=$2

#fail if one of the commands fails
#BUG it's not possible to set this flag, as monkeydo returns a non-zero exit code even when tests succeed
#set -e

#kill child processes when this scripts exists
trap 'kill $(jobs -p)' EXIT

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

monkeyc -f monkey.jungle -d "$DEVICE_ID" -o bin/app.prg -y "$CERTIFICATE_PATH" -t -l 3

#check if the compiler produced a resulting program file
if [[ ! -f bin/app.prg ]]; then
	info "Compilation failed!"
	exit 1
fi

info "Build success!"

