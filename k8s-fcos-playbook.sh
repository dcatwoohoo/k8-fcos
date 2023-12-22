#!/bin/bash

# For constant teardown and rebuild
export ANSIBLE_HOST_KEY_CHECKING=False

#./ovf.sh

#echo "Sleeping 45  seconds to allow for power on"
#sleep 45

ansible-playbook -i ansible/inventory ansible/k8s-fcos-playbook.yaml
