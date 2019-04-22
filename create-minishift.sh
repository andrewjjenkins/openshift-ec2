#!/usr/bin/env bash

set -euo pipefail

ME=`whoami`
STACKNAME="${STACKNAME:-$ME-minishift-dev}"
if [ -z "${KEYNAME:-}" ]; then
  echo "You must provide KEYNAME, the name of an SSH keypair in EC2"
  echo "  KEYNAME=andrews-ssh-key ./create-minishift.sh"
fi

aws cloudformation create-stack --stack-name $STACKNAME --template-body file://./cft.yaml --parameters ParameterKey=KeyName,ParameterValue=$KEYNAME
aws cloudformation wait stack-create-complete --stack-name $STACKNAME
BUILDIP=$(aws cloudformation describe-stacks --stack-name $STACKNAME | jq -r '.Stacks[0].Outputs[] | select(.OutputKey=="InstanceIPAddress") | .OutputValue')

echo "Stack created."
echo "Login with ssh command:"
echo "  ssh ubuntu@$BUILDIP"
echo "Delete the stack when you're done with:"
echo "  aws cloudformation delete-stack --stack-name $STACKNAME"
