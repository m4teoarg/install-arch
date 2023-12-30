#!/bin/env bash

clear
loadkeys la-latin1
echo -e "\t\e[33mTeclado latam.\e[0m"
sleep 3
clear
#          Verificación de conexión a la red
echo -e "\t\e[33m-------------------------------\e[0m"
echo -e "\t\e[33m-------------------------------\e[0m"
echo -e "\t\e[33mVerificando conección a la red.\e[0m"
echo -e "\t\e[33m-------------------------------\e[0m"
sleep 2
clear
network() {
	testping=$(ping -q -c 1 -W 1 archlinux.org >/dev/null)

	if $testping; then
		ipx=$(curl -s www.icanhazip.com)
		isp=$(lynx -dump https://www.iplocation.net | grep "ISP:" | cut -d ":" -f 2- | cut -c 2-200)
		echo -e "IP: \e[32m$ipx\e[0m ISP: \e[32m$isp\e[0m"
	else
		echo -e "\e[31mProblema de red o desconectado\e[0m"
	fi
	pingx=$(ping -c 1 archlinux.org | head -n2)
	echo -e "\e[90m$pingx\e[0m"
	echo ""
	sleep 3
}

echo -e "\t\e[33mEstado de conexión...\e[0m"

if ping -q -c 2 -W 2 8.8.8.8 >/dev/null; then
	network
else
	echo -e "\t\e[31mSistema desconectado\e[0m"
fi

echo ""
sleep 3
clear

# Actualizando archlinux  keyring
echo -e "\t\e[33m------------------------------\e[0m"
echo -e "\t\e[33mActualizando archlinux-keyring\e[0m"
echo -e "\t\e[33m------------------------------\e[0m"
pacman -Sy archlinux-keyring --noconfirm

confir
clear

CRE=$(tput setaf 1)
CYE=$(tput setaf 3)
CGR=$(tput setaf 2)
CBL=$(tput setaf 4)
CBO=$(tput bold)
CNC=$(tput sgr0)
CHROOT="arch-chroot /mnt"

titleopts() {

	local textopts="${1:?}"
	printf " \n%s>>>%s %s%s%s\n" "${textopts}"
}

confir() {
	printf "\e[32mOk\e[0m"
	sleep 2
}

conten() {

	local text="${1:?}"
	printf ' "\e[33m%s%s[%s %s %s]%s\n\n\e[0m"' "${text}"
}

echo ""
confir
echo ""
echo -e "\t\e[33m-------------------\e[0m"
echo -e "\t\e[33mModo de Arranque\e[0m"
echo -e "\t\e[33m-------------------\e[0m"
echo ""
sleep 3

if [ -d /sys/firmware/efi/efivars ]; then
	bootmode="uefi"
	echo -e "\t\e[33m-----------------------------------\e[0m"
	echo -e "\t\e[33mEl escript se ejecutara en modo EFI\e[0m"
	echo -e "\t\e[33m-----------------------------------\e[0m"
	sleep 3
	clear
else
	bootmode="mbrbios"
	echo -e "\t\e[33m----------------------------------------\e[0m"
	echo -e "\t\e[33mEl escript se ejecutara en modo BIOS/MBR\e[0m"
	echo -e "\t\e[33m----------------------------------------\e[0m"
	sleep 3
	clear
fi

#          Obteniendo información usuario, root, Hostname
echo -e "\t\e[33m--------------------------------\e[0m"
echo -e "\t\e[33mObteniendo información necesaria\e[0m"
echo -e "\t\e[33m--------------------------------\e[0m"
sleep 3
while true; do
	USR=$(whiptail --inputbox "Ingresa tu usuario:" 10 50 3>&1 1>&2 2>&3)
	if [[ "${USR}" =~ ^[a-z][_a-z0-9-]{0,30}$ ]]; then
		break
	else
		whiptail --msgbox "Incorrecto!! Solo se permiten minúsculas." 10 50
	fi
done

while true; do
	PASSWD=$(whiptail --passwordbox "Ingresa tu password:" 10 50 3>&1 1>&2 2>&3)
	CONF_PASSWD=$(whiptail --passwordbox "Confirma tu password:" 10 50 3>&1 1>&2 2>&3)

	if [ "$PASSWD" != "$CONF_PASSWD" ]; then
		whiptail --msgbox "Las contraseñas no coinciden. Intenta nuevamente." 10 50
	else
		whiptail --msgbox "Contraseña confirmada correctamente." 10 50
		break
	fi
done

while true; do
	PASSWDR=$(whiptail --passwordbox "Ingresa tu password para ROOT:" 10 50 3>&1 1>&2 2>&3)
	CONF_PASSWDR=$(whiptail --passwordbox "Confirma tu password:" 10 50 3>&1 1>&2 2>&3)

	if [ "$PASSWDR" != "$CONF_PASSWDR" ]; then
		whiptail --msgbox "Las contraseñas no coinciden. Intenta nuevamente." 10 50
	else
		whiptail --msgbox "Contraseña confirmada correctamente." 10 50
		break
	fi
done

while true; do
	HNAME=$(whiptail --inputbox "Ingresa el nombre de tu máquina:" 10 50 3>&1 1>&2 2>&3)
	if [[ "$HNAME" =~ ^[a-z][a-z0-9_.-]{0,62}[a-z0-9]$ ]]; then
		break
	else
		whiptail --msgbox "Incorrecto!! El nombre no puede incluir mayúsculas ni símbolos especiales." 10 50
	fi
done

clear
PS3="Quieres instalar PARU como AUR Helper?: "
	select PARUH in "Si" "No"
		do
			if [ $PARUH ]; then
				break
			fi
		done
confir
sleep 3
clear
#          Seleccionar DISCO
echo -e "\t\e[33m---------------------------------------\e[0m"
echo -e "\t\e[33mSelecciona el disco para la instalación\e[0m"
echo -e "\t\e[33m---------------------------------------\e[0m"

# Mostrar información de los discos disponibles
echo -e "\t\e[33m-------------------\e[0m"
echo -e "\t\e[33mDiscos disponibles:\e[0m"
echo -e "\t\e[33m-------------------\e[0m"
echo ""
lsblk -d -e 7,11 -o NAME,SIZE,TYPE,MODEL
echo "----"
echo ""

# Seleccionar el disco para la instalación de Arch Linux
echo -e "\t\e[33m--------------------------------------\e[0m"
PS3="Escoge la partición donde Arch Linux se instalara: "
select drive in $(lsblk -d | awk '{print "/dev/" $1}' | grep 'sd\|hd\|vd\|nvme\|mmcblk'); do
	if [ "$drive" ]; then
		break
	fi
done
sleep 3
clear

#          Creando particion
echo -e "\t\e[33m-------------------\e[0m"
echo -e "\t\e[33mCreando Particiones\e[0m"
echo -e "\t\e[33m-------------------\e[0m"

cfdisk "${drive}"
clear

#		Sistema UEFI
echo -e "\t\e[33m-------------------------------------------\e[0m"
echo -e "\t\e[33mCreando, Formateando y Montando Particiones\e[0m"
echo -e "\t\e[33m-------------------------------------------\e[0m"

	if [ "$bootmode" == "uefi" ]; then
	
		cfdisk "${drive}"
		sleep 3
		partx -u "${drive}"
		clear

echo -e "\t\e[33m---------------------------\e[0m"
echo -e "\t\e[33mSelecciona tu particion EFI\e[0m"
echo -e "\t\e[33m---------------------------\e[0m"

		lsblk "${drive}" -I 8 -o NAME,SIZE,PARTTYPENAME
		echo
			
PS3="Escoge la particion EFI que acabas de crear: "
	select efipart in $(fdisk -l "${drive}" | grep EFI | cut -d" " -f1) 
		do
			if [ "$efipart" ]; then	
			
				break
			fi 
			clear
		done
		
		else
			cfdisk "${drive}"
			clear
	fi

echo -e "\t\e[33m-------------------------------------------\e[0m"
echo -e "\t\e[33mCreando, Formatenado y Montando Particiones\e[0m"
echo -e "\t\e[33m-------------------------------------------\e[0m"

			echo
			lsblk "${drive}" -I 8 -o NAME,SIZE,FSTYPE,PARTTYPENAME
			echo

#		Sistema BIOS			
PS3="Escoge la particion raiz que acabas de crear donde Arch Linux se instalara: "
	select partroot in $(fdisk -l "${drive}" | grep Linux | cut -d" " -f1) 
		do
			if [ "$partroot" ]; then
				printf " \nFormateando la particion RAIZ %s\n Espere..\n" "${partroot}"
				sleep 3
				mkfs.ext4 -L Arch "${partroot}" >/dev/null 2>&1
				mount "${partroot}" /mnt
				sleep 3	
				break
			fi
		done
					
			
	if [ "$bootmode" == "uefi" ]; then
	
			printf "\n Formateando y montando la particion EFI\n Espere..\n"
			sleep 3
			mkdir -p /mnt/efi
			mkfs.fat -F 32 "${efipart}" >/dev/null 2>&1
			mount "${efipart}" /mnt/efi
			sleep 3
	fi
			confir
			clear

echo -e "\t\e[33m-------------------\e[0m"
echo -e "\t\e[33m-----Procesando----\e[0m"		
echo -e "\t\e[33m-------------------\e[0m"
sleep 2
confir
clear

#          Creando y Montando SWAP
echo -e "\t\e[33m-------------------\e[0m"
echo -e "\t\e[33m-Configurando SWAP-\e[0m"
echo -e "\t\e[33m-------------------\e[0m"
PS3="Escoge la particion SWAP: "
select swappart in $(fdisk -l | grep -E "swap" | cut -d" " -f1) "No quiero swap" "Crear archivo swap"; do
	if [ "$swappart" = "Crear archivo swap" ]; then

		printf "\n Creando archivo swap..\n"
		sleep 2
		fallocate -l 2048M /mnt/swapfile
		chmod 600 /mnt/swapfile
		mkswap -L SWAP /mnt/swapfile >/dev/null
		printf " Montando Swap, espera..\n"
		swapon /mnt/swapfile
		sleep 2
		confir
		break

	elif [ "$swappart" = "No quiero swap" ]; then

		break

	elif [ "$swappart" ]; then

		echo
		printf " \nFormateando la particion swap, espera..\n"
		sleep 2
		mkswap -L SWAP "${swappart}" >/dev/null 2>&1
		printf " Montando Swap, espera..\n"
		swapon "${swappart}"
		sleep 2
		confir
		break
	fi
done
clear

#          Información
echo -e "\t\e[33m---------INFO----------\e[0m"
printf "\n\n%s\n\n" "--------------------"
printf " User:      %s%s%s\n" "${CBL}" "$USR" "${CNC}"
printf " Hostname:  %s%s%s\n" "${CBL}" "$HNAME" "${CNC}"

if [ "$swappart" = "Crear archivo swap" ]; then
	printf " Swap:      %sSi%s se crea archivo swap de 2G\n" "${CGR}" "${CNC}"
elif [ "$swappart" = "No quiero swap" ]; then
	printf " Swap:      %sNo%s\n" "${CRE}" "${CNC}"
elif [ "$swappart" ]; then
	printf " Swap:      %sSi%s en %s[%s%s%s%s%s]%s\n" "${CGR}" "${CNC}" "${CYE}" "${CNC}" "${CBL}" "${swappart}" "${CNC}" "${CYE}" "${CNC}"
fi

if [ "${PARUH}" = "Si" ]; then
	printf " Paru:       %sSi%s\n" "${CGR}" "${CNC}"
else
	printf " Paru:       %sNo%s\n" "${CRE}" "${CNC}"
fi

echo
echo -e "\t\e[33m--------------------------------------------------------------\e[0m"
printf "\n Arch Linux se instalara en el disco %s[%s%s%s%s%s]%s en la particion %s[%s%s%s%s%s]%s\n\n\n" "${CYE}" "${CNC}" "${CRE}" "${drive}" "${CNC}" "${CYE}" "${CNC}" "${CYE}" "${CNC}" "${CBL}" "${partroot}" "${CNC}" "${CYE}" "${CNC}"
echo -e "\t\e[33m--------------------------------------------------------------\e[0m"
sleep 2

while true; do
	read -rp " ¿Deseas continuar? [s/N]: " sn
	case $sn in
	[Ss]*) break ;;
	[Nn]*) exit ;;
	*) printf " Error: solo necesitas escribir 's' o 'n'\n\n" ;;
	esac
done

#          Pacstrap base system
echo -e "\t\e[33m-----------------------\e[0m"
echo -e "\t\e[33mInstalando sistema base\e[0m"
echo -e "\t\e[33m-----------------------\e[0m"
pacstrap /mnt base base-devel linux linux-firmware networkmanager xdg-user-dirs nano git

sleep 3
confir
clear

#          Generating FSTAB
echo -e "\t\e[33m-------------------\e[0m"
echo -e "\t\e[33m--Generando FSTAB--\e[0m"
echo -e "\t\e[33m-------------------\e[0m"

genfstab -U /mnt >>/mnt/etc/fstab

sleep 3
confir
clear

#          Timezone, Lang & Keyboard
echo -e "\t\e[33m-------------------------------\e[0m"
echo -e "\t\e[33mConfigurando Timezone y Locales\e[0m"
echo -e "\t\e[33m-------------------------------\e[0m"

$CHROOT ln -sf /usr/share/zoneinfo/America/Argentina/Buenos_Aires /etc/localtime
$CHROOT hwclock --systohc
echo
echo "es_AR.UTF-8 UTF-8" >>/mnt/etc/locale.gen
$CHROOT locale-gen
echo "LANG=es_AR.UTF-8" >>/mnt/etc/locale.conf
echo "KEYMAP=la-latin1" >>/mnt/etc/vconsole.conf
export LANG=es_AR.UTF-8
sleep 3
confir
clear

#          Hostname & Hosts
echo -e "\t\e[33m---------------------\e[0m"
echo -e "\t\e[33mConfigurando Internet\e[0m"
echo -e "\t\e[33m---------------------\e[0m"

echo "${HNAME}" >>/mnt/etc/hostname
cat >>/mnt/etc/hosts <<-EOL
	127.0.0.1   localhost
	::1         localhost
	127.0.1.1   ${HNAME}.localdomain ${HNAME}
EOL
sleep 3
confir
clear

#          Users & Passwords
echo -e "\t\e[33m-------------------\e[0m"
echo -e "\t\e[33mUsuario Y Passwords\e[0m"
echo -e "\t\e[33m-------------------\e[0m"

echo "root:$PASSWDR" | $CHROOT chpasswd
$CHROOT useradd -m -g users -G wheel "${USR}"
echo "$USR:$PASSWD" | $CHROOT chpasswd
sed -i 's/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/; /^root ALL=(ALL:ALL) ALL/a '"${USR}"' ALL=(ALL:ALL) ALL' /mnt/etc/sudoers
echo "Defaults insults" >>/mnt/etc/sudoers
printf " %sroot%s : %s%s%s\n %s%s%s : %s%s%s\n" "${CBL}" "${CNC}" "${CRE}" "${PASSWDR}" "${CNC}" "${CYE}" "${USR}" "${CNC}" "${CRE}" "${PASSWD}" "${CNC}"
confir
sleep 7
clear

echo -e "\t\e[33m-------------------\e[0m"
echo -e "\t\e[33m--Instalando GRUB--\e[0m"
echo -e "\t\e[33m-------------------\e[0m"

if [ "$bootmode" == "uefi" ]; then

	$CHROOT pacman -S grub efibootmgr os-prober ntfs-3g --noconfirm >/dev/null
	$CHROOT grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=Arch
else
	$CHROOT pacman -S grub os-prober ntfs-3g --noconfirm >/dev/null
	$CHROOT grub-install --target=i386-pc "$drive"
fi

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
