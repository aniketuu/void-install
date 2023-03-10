#!/bin/bash

printf "\033c" #reset the terminal
echo "Void Linux install post base installation"

if [ $EUID -ne 0 ]; then
 echo "Please run as super user"
 exit 1
fi

# enable non-free repo and 32 bit repos
echo "Enabling non-free repo"
xbps-install void-repo-nonfree
sleep 1s

# 32 bit stuff
read -p "want 32-bit packages? [y/N] " BIT32
if [ $BIT32 == "y" ]; then
  xbps-install void-repo-multilib void-repo-multilib-nonfree
  sleep 1s
fi

# setup mirror (I am using Singapore, Asia)
echo "Changing mirrors"
cp /usr/share/xbps.d/*-repository-*.conf /etc/xbps.d/
sed -i 's|https://repo-default.voidlinux.org|https://void.webconverger.org/|g' /etc/xbps.d/*-repository-*.conf

# sync and update
echo "System update"
xbps-install -Suv
sleep 1s

# TODO: figureout fstrim /

# ucode
echo "Installing ucode"
xbps-install -Suv intel-ucode
sleep 1s

# # dbus
# read -p "enable dbus and elogind manually? [y/N] " DBUS
# if [ $DBUS == "y" ]; then
#   xbps-install -Sv dbus elogind
#   sleep 1s
#   ln -s /etc/sv/dbus/ /var/service
#   ln -s /etc/sv/elogind/ /var/service
# fi

# # xorg
# read -p "install xorg manually? [y/N] " XORG
# if [ $XORG == "y" ]; then
#   xbps-install -Sv xorg
#   sleep 1s
# fi

# utilities
echo "Installing utilities"
xbps-install -Suv mesa-demos python3-usb xterm bash-completion qbittorrent mpv alacritty bluez bluez-alsa firefox
sleep 1s

# bluetooth
usermod -aG bluetooth $SUDO_USER
ln -s /etc/sv/bluetoothd/ /var/service

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

