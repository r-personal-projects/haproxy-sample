#!/bin/bash

# requires to run with sudo
if [[ $UID != 0 ]]; then
    echo "Please run this script with sudo:"
    echo "sudo $0 $*"
    exit 1
fi

# some sample usages
if [ "$1" == "" ] || [ $# -gt 1 ] || [ $# -ne 1 ]; then
        echo "Usage: ./add-new-cert.sh <domain>"
        echo "f.e.: ./add-new-cert.sh domain.rubeen.one"
        exit 1;
fi;

# switch to actual folder
cd "${0%/*}"

# add domain to domainList
echo "$1" >> ./domains.list
# run renewal-script
sudo ./renewal