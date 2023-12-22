#!/bin/bash

#Refreshing ignition
echo "Refreshing Ignition"
docker run -i --rm quay.io/coreos/butane:release --pretty --strict < ignition/butane.yaml > ignition/ignition.json

CONFIG_ENCODING='gzip+base64'
CONFIG_ENCODED=$(cat ignition/ignition.json | gzip -9 | base64)
LIBRARY="$HOME/Virtual Machines.localized"
FCOS_OVA=~/Documents/ISOs/fedora-coreos-39.20231119.3.0-vmware.x86_64.ova

for VM_NAME in fcos-node01 fcos-node02
do
  echo "Instantiating OVF to $VM_NAME"
  /Applications/VMware\ Fusion.app/Contents/Library/VMware\ OVF\ Tool/ovftool \
    --powerOffTarget \
    --name="${VM_NAME}" \
    --allowExtraConfig \
    --extraConfig:guestinfo.ignition.config.data.encoding="${CONFIG_ENCODING}" \
    --extraConfig:guestinfo.ignition.config.data="${CONFIG_ENCODED}" \
    "${FCOS_OVA}" "${LIBRARY}"

  # Find VMX location
  VMX=$(find "$LIBRARY" -name '*.vmx' | grep "$VM_NAME")

  echo "Setting up networking on $VM_NAME"
  vmrun -T fusion setNetworkAdapter "$VMX" 0 nat

  echo "Powering On $VM_NAME"
  vmrun -T fusion start "$VMX" gui
done

echo "Sleeping 45 seconds to let the VMs boot"
sleep 45