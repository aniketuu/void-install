#!/bin/bash

printf "\033c" #reset the terminal
echo "setup GVT-g"

if [ $EUID -ne 0 ]; then
 echo "Please run as super user"
 exit 1
fi

# enable iommu
sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT="loglevel=4"$/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=4 intel_iommu=on i915.enable_gvt=1 i915.enable_guc=0 kvm.ignore_msrs=1"/' /etc/default/grub
update-grub

# load modules
echo "kvmgt" > /etc/modules-load.d/gvt-g.conf
echo "vfio-iommu-type1" > /etc/modules-load.d/gvt-g.conf
echo "mdev" > /etc/modules-load.d/gvt-g.conf
dracut --regenerate-all --force

# TODO: create runit service to load the vGPU at reboot

