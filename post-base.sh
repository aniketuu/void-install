#!/bin/bash

printf "\033c" #reset the terminal
echo "Void Linux install post base installation"

if [ $EUID -ne 0 ]; then
 echo "Please run as super user"
 exit 1
fi

# enable non-free repo and 32 bit repos
xbps-install void-repo-nonfree

# 32 bit stuff
read -p "want 32-bit packages? [y/N] " BIT32
if [ $BIT32 == "y" ]; then
  xbps-install void-repo-multilib void-repo-multilib-nonfree
fi

# setup mirror (I am using Singapore, Asia)
cp /usr/share/xbps.d/*-repository-*.conf /etc/xbps.d/
sed -i 's|https://repo-default.voidlinux.org|https://void.webconverger.org/|g' /etc/xbps.d/*-repository-*.conf

# sync and update
xbps-install -Suv

# TODO: figureout fstrim /

# ucode
xbps-install -Suv intel-ucode

# nvidia
read -p "using nvidia? [y/N] " NVI
if [ $NVI == "y" ]; then
  xbps-install -Suv nvidia nvidia-libs nvidia-libs-32bit nvidia-dkms nvidia-firmware
  if [ $BIT32 == "y" ]; then
    xbps-install -Suv nvidia-libs-32bit
  fi
fi

# steam
read -p "want steam? [y/N] " STEAM
if [ $STEAM == "y" ]; then
    if [ $BIT32 != "y" ]; then
      echo "Enable 32 BIT first"
    fi
  xbps-install -Suv libgcc-32bit libstdc++-32bit libdrm-32bit libglvnd-32bit mesa-dri-32bit libgcc-32bit libstdc++-32bit libdrm-32bit libglvnd-32bit steam
fi

# utilities
xbps-install -Suv mesa-demos python3-usb xterm

# install qemu/kvm
read -p "install qemu/kvm? [y/N] " VM
if [[ $VM = "y" ]]; then
  # install stuff
  xbps-install libvirt virt-manager virt-manager-tools qemu qemu-ga
  
  # premissions
  usermod -aG kvm $SUDO_USER
  usermod -aG libvirt $SUDO_USER
  
  modprobe kvm-intel
  
  # enable services
  ln -s /etc/sv/libvirtd/ /var/service
  ln -s /etc/sv/virtlockd/ /var/service
  ln -s /etc/sv/virtlogd/ /var/service
  
  mkdir /var/lib/libvirt/isos
fi

echo "please reboot your system"

