sed -i 's/quiet/zswap.enabled=0 mitigations=off nowatchdog/; s/#GRUB_DISABLE_OS_PROBER/GRUB_DISABLE_OS_PROBER/' /mnt/etc/default/grub
echo
$CHROOT grub-mkconfig -o /boot/grub/grub.cfg
confir
sleep 4
clear

#          Refreshing Mirrors
echo -e "\t\e[33m------------------------------------------\e[0m"
echo -e "\t\e[33mRefrescando mirros en la nueva Instalacion\e[0m"
echo -e "\t\e[33m------------------------------------------\e[0m"

reflector --verbose --latest 5 --country 'United States' --age 6 --sort rate --save /etc/pacman.d/mirrorlist >/dev/null 2>&1
pacman -Syy
sleep 4
echo ""
confir
clear
echo ""

#		Instalando gnome y servicios
echo -e "\t\e[33m----------------------\e[0m"
echo -e "\t\e[33mInstalando gnome y gdm\e[0m"
echo -e "\t\e[33m----------------------\e[0m"
# 		Instala GNOME, GDM y NetworkManager

$CHROOT pacman -S gnome gdm pipewire pipewire-pulse firewalld firefox git nano neofetch gparted neovim gum tmux jq unzip zip unarj xdg-utils --noconfirm
echo ""
confir
sleep 3
clear

# Activando servicio
echo -e "\t\e[33m-------------------\e[0m"
echo -e "\t\e[33mActivando Servicios\e[0m"
echo -e "\t\e[33m-------------------\e[0m"

$CHROOT systemctl enable NetworkManager.service
$CHROOT systemctl enable gdm.service
#echo "xdg-user-dirs-update" | $CHROOT su "$USR"
sleep 5
confir
clear
#          Xorg

cat >>/mnt/etc/X11/xorg.conf.d/00-keyboard.conf <<EOL
Section "InputClass"
		Identifier	"system-keyboard"
		MatchIsKeyboard	"on"
		Option	"XkbLayout"	"latam"
EndSection
EOL
printf "%s00-keyboard.conf%s generated in --> /etc/X11/xorg.conf.d\n" "${CGR}" "${CNC}"

confir
clear

#		Instalando paru
echo -e "\t\e[33m---------------------------\e[0m"
echo -e "\t\e[33mClonando e instalando paru.\e[0m"
echo -e "\t\e[33m---------------------------\e[0m"
sleep 3
clear
if [ "${PARUH}" == "Si" ]; then
	echo -e "\t\e[33m----------------\e[0m"
	echo -e "\t\e[33mInstalando paru.\e[0m"
	echo -e "\t\e[33m----------------\e[0m"
	sleep 2
		echo "cd && git clone https://aur.archlinux.org/paru.git && cd paru && makepkg -si --noconfirm && cd" | $CHROOT su "$USR"
	clear
fi
confir
sleep 3
#echo "cd && git clone https://aur.archlinux.org/paru.git && cd paru && makepkg -si --noconfirm && cd" | $CHROOT su "$USR"
echo -e "\t\e[33m-------------------------------------------------------------------------\e[0m"
echo -e "\t\e[33mInstalando tdrop-git, gnome-tweaks, extension-manager, papirus-icon-theme\e[0m"
echo -e "\t\e[33m-------------------------------------------------------------------------\e[0m"
confir
clear
echo "cd && paru -S tdrop-git --skipreview --noconfirm --removemake" | $CHROOT su "$USR"
echo "cd && paru -S gnome-tweaks --skipreview --noconfirm --removemake" | $CHROOT su "$USR"
echo "cd && paru -S extension-manager --skipreview --noconfirm --removemake" | $CHROOT su "$USR"
echo "cd && paru -S papirus-icon-theme --skipreview --noconfirm --removemake" | $CHROOT su "$USR"
#echo "cd && paru -S eww-x11 simple-mtpfs tdrop-git --skipreview --noconfirm --removemake" | $CHROOT su "$USR"
#echo "cd && paru -S zramswap stacer --skipreview --noconfirm --removemake" | $CHROOT su "$USR"
#echo "cd && paru -S spotify spotify-adblock-git mpv-git popcorntime-bin --skipreview --noconfirm --removemake" | $CHROOT su "$USR"
#echo "cd && paru -S whatsapp-nativefier telegram-desktop-bin simplescreenrecorder --skipreview --noconfirm --removemake" | $CHROOT su "$USR"
#echo "cd && paru -S cmatrix-git transmission-gtk3 qogir-icon-theme --skipreview --noconfirm --removemake" | $CHROOT su "$USR"
sleep 3
confir
clear

#   instalando core-gtk-theme
echo -e "\t\e[33m----------------------------------------\e[0m"
echo -e "\t\e[33mDescargando e instalando core-gtk-theme.\e[0m"
echo -e "\t\e[33m----------------------------------------\e[0m"
sleep 3
echo "cd && git clone https://github.com/ArchItalia/core-gtk-theme.git && cd core-gtk-theme && makepkg -si --noconfirm && cd" | $CHROOT su "$USR"
confir
sleep 3
clear
# instalando core-gnome-backgroun
echo -e "\t\e[33m------------------------------------------------\e[0m"
echo -e "\t\e[33mDescargando e instalando core-gnome-backgrounds.\e[0m"
echo -e "\t\e[33m------------------------------------------------\e[0m"
sleep 3
echo "cd && git clone https://github.com/ArchItalia/core-gnome-backgrounds.git && cd core-gnome-backgrounds && makepkg -si --noconfirm && cd" | $CHROOT su "$USR"
confir
sleep 3
clear
#	instalando architalia-fonts 
echo -e "\t\e[33m------------------------------------------\e[0m"
echo -e "\t\e[33mDescargando e instalando Architalia-fonts.\e[0m"
echo -e "\t\e[33m------------------------------------------\e[0m"
sleep 3
echo "cd && git clone https://github.com/ArchItalia/architalia-fonts.git && cd architalia-fonts && makepkg -si --noconfirm && cd" | $CHROOT su "$USR"
sleep 3
confir
echo ""
clear

#          Reversión de privilegios sin contraseña

sed -i 's/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /mnt/etc/sudoers

sleep 3
confir
clear

echo -e "\t\e[33m-----------------------------------------\e[0m"
echo -e "\t\e[33mLimpiando sistema para su primer arranque\e[0m"
echo -e "\t\e[33m-----------------------------------------\e[0m"
sleep 2
rm -rf /mnt/home/"$USR"/.cache/paru/
rm -rf /mnt/home/"$USR"/.cache/electron/
rm -rf /mnt/home/"$USR"/.cache/go-build/
rm -rf /mnt/home/"$USR"/{paru,.cargo,.rustup}

$CHROOT pacman -Scc
$CHROOT pacman -Rns go --noconfirm >/dev/null 2>&1
$CHROOT pacman -Rns "$(pacman -Qtdq)" >/dev/null 2>&1
$CHROOT fstrim -av >/dev/null
sleep 2
confir
clear
# Confirmación de reinicio
while true; do
	sn=$(whiptail --yesno "¿Quieres reiniciar ahora?" 10 60 3>&1 1>&2 2>&3)
	if [ $? -eq 0 ]; then
		umount -R >/dev/null 2>&1
		reboot
	else
		exit
	fi
done
