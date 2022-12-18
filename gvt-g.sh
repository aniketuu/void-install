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
mkdir /etc/sv/setup-gvt-g
echo 'echo 1e0d01e0-fe65-438a-9120-2066570851f4 > /sys/devices/pci0000:00/0000:00:02.0/mdev_supported_types/i915-GVTg_V5_4/create' > /etc/sv/setup-gvt-g/run
chmod +x /etc/sv/setup-gvt-g/run
