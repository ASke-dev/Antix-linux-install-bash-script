#!/bin/bash

export DISK_ROOT="/dev/nvme0n1p4"
export DISK_EFI="/dev/nvme0n1p1"


mkfs.ext4 -F $DISK_ROOT
mount $DISK_ROOT /mnt
mkdir -p /mnt/boot/efi
mount $DISK_EFI /mnt/boot/efi


echo "Server = https://mirror.yandex.ru/artix-linux/repos/\$repo/os/\$arch" > /etc/pacman.d/mirrorlist
echo "Server = http://mirror.linux.kz/artixlinux/\$repo/os/\$arch" >> /etc/pacman.d/mirrorlist


basestrap /mnt base dinit linux-zen linux-firmware nano networkmanager-dinit sudo networkmanager

fstabgen -U /mnt >> /mnt/etc/fstab


artix-chroot /mnt /bin/bash <<EOC
ln -sf /usr/share/zoneinfo/Asia/Bishkek /etc/localtime
hwclock --systohc
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "arti" > /etc/hostname
echo "root:arch" | chpasswd
useradd -m -G wheel,video,audio,storage aske
echo "aske:arch" | chpasswd



pacman -S --noconfirm grub efibootmgr os-prober
echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=artix
grub-mkconfig -o /boot/grub/grub.cfg

EOC
