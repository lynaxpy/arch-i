
#!/bin/bash

echo "Formating partions"
mkfs.fat -F32 /dev/sda1
mkfs.ext4 /dev/sda2
mkfs.ext4 /dev/sda3

echo "Mounting partions"
rm -rf /mnt
mkdir /mnt
mount /dev/sda2 /mnt
mkdir /mnt/boot
mkdir /mnt/home
mount /dev/sda1 /mnt/boot
mount /dev/sda3 /mnt/home

echo "Installing basic system"
pacstrap /mnt base base-devel linux linux-firmware 

echo "Generetaing fstab"
genfstab -U /mnt >> /mnt/etc/fstab

echo "Moving to chroot env"
arch-chroot /mnt /bin/bash <<EOF


echo "Installing and setting up bootloader"
pacman -S --noconfirm grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

echo "Creating Users"
useradd -m -G wheel -s /bin/bash lynax
echo "lynax:password" | chpasswd
echo "root:password" | chpasswd

echo "Setting up sudo"
sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

echo "Installing GDM and NetworkManager"
pacman -S --noconfirm gdm gnome networkmanager hyprland kitty net-tools nano intel-ucode git bluez bluez-utils firefox

systemctl enable gdm
systemctl enable NetworkManager

EOF

echo "Installing finished! Reboot system"


