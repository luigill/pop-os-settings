#!/usr/bin/env bash
#
# pos-os-postinstall.sh - Instalar e configura programas no Pop!_OS (20.04 LTS ou superior)
#
# Website:       https://diolinux.com.br
# Autor:         Dionatan Simioni
#
# ------------------------------------------------------------------------ #
#
# COMO USAR?
#   $ ./post-install.sh
#
# ----------------------------- VARIÁVEIS ----------------------------- #
set -e

##URLS

URL_OBSIDIAN="https://github.com/obsidianmd/obsidian-releases/releases/download/v1.5.12/obsidian_1.5.12_amd64.deb"

##DIRETÓRIOS E ARQUIVOS

DIRETORIO_DOWNLOADS="$HOME/Downloads/programas"
FILE="/home/$USER/.config/gtk-3.0/bookmarks"

#CORES

VERMELHO='\e[1;91m'
VERDE='\e[1;92m'
SEM_COR='\e[0m'

#FUNÇÕES

# Atualizando repositório e fazendo atualização do sistema

apt_update() {
	sudo apt update && sudo apt dist-upgrade -y
}

# -------------------------------------------------------------------------------- #
# -------------------------------TESTES E REQUISITOS----------------------------------------- #

# Internet conectando?
testes_internet() {
	if ! ping -c 1 8.8.8.8 -q &>/dev/null; then
		echo -e "${VERMELHO}[ERROR] - Seu computador não tem conexão com a Internet. Verifique a rede.${SEM_COR}"
		exit 1
	else
		echo -e "${VERDE}[INFO] - Conexão com a Internet funcionando normalmente.${SEM_COR}"
	fi
}

# ------------------------------------------------------------------------------ #

## Adicionando/Confirmando arquitetura de 32 bits ##
add_archi386() {
	sudo dpkg --add-architecture i386
}
## Atualizando o repositório ##
just_apt_update() {
	sudo apt update -y
}

##DEB SOFTWARES TO INSTALL

PROGRAMAS_PARA_INSTALAR=(
	gparted
	timeshift
	vlc
	code
	git
	wget
	build-essential
	gnome-tweaks
	openjdk-21-jdk
	htop
	ranger
	zathura
)

# ---------------------------------------------------------------------- #

## Download e instalaçao de programas externos ##

install_debs() {

	echo -e "${VERDE}[INFO] - Baixando pacotes .deb${SEM_COR}"

	mkdir "$DIRETORIO_DOWNLOADS"
	wget -c "$URL_OBSIDIAN" -P "$DIRETORIO_DOWNLOADS"

	## Instalando pacotes .deb baixados na sessão anterior ##
	echo -e "${VERDE}[INFO] - Instalando pacotes .deb baixados${SEM_COR}"
	sudo dpkg -i $DIRETORIO_DOWNLOADS/*.deb

	# Instalar programas no apt
	echo -e "${VERDE}[INFO] - Instalando pacotes apt do repositório${SEM_COR}"

	for nome_do_programa in ${PROGRAMAS_PARA_INSTALAR[@]}; do
		if ! dpkg -l | grep -q $nome_do_programa; then # Só instala se já não estiver instalado
			sudo apt install "$nome_do_programa" -y
		else
			echo "[INSTALADO] - $nome_do_programa"
		fi
	done

}
## Instalando pacotes Flatpak ##
install_flatpaks() {

	echo -e "${VERDE}[INFO] - Instalando pacotes flatpak${SEM_COR}"

	flatpak install flathub com.obsproject.Studio -y
	flatpak install flathub org.gimp.GIMP -y
	flatpak install flathub com.spotify.Client -y
	flatpak install flathub com.bitwarden.desktop -y
	flatpak install flathub md.obsidian.Obsidian -y
	flatpak install flathub org.gnome.Boxes -y
	flatpak install flathub org.qbittorrent.qBittorrent -y
	flatpak install flathub com.discordapp.Discord -y
	flatpak install flathub com.brave.Browser -y
	flatpak install flathub com.stremio.Stremio -y
	flatpak install flathub com.mattjakeman.ExtensionManager -y
}

# -------------------------------------------------------------------------- #
# ----------------------------- PÓS-INSTALAÇÃO ----------------------------- #

## Finalização, atualização e limpeza##

system_clean() {

	apt_update -y
	flatpak update -y
	sudo apt autoclean -y
	sudo apt autoremove -y
	nautilus -q
}

# -------------------------------------------------------------------------- #
# ----------------------------- CONFIGS EXTRAS ----------------------------- #

#Cria pastas para produtividade no nautilus
extra_config() {

	mkdir /home/$USER/AppImage
	mkdir /home/$USER/Videos/'OBS Rec'
	mkdir /home/$USER/source

	#Adiciona atalhos ao Nautilus

	if test -f "$FILE"; then
		echo "$FILE já existe"
	else
		echo "$FILE não existe, criando..."
		touch /home/$USER/.config/gkt-3.0/bookmarks
	fi

	echo "file:///home/$USER/source" >>$FILE
	echo "file:///home/$USER/AppImage" >>$FILE
}

# -------------------------------------------------------------------------------- #
# -------------------------------EXECUÇÃO----------------------------------------- #

testes_internet
apt_update
add_archi386
just_apt_update
install_debs
install_flatpaks
extra_config
apt_update
system_clean

## finalização

echo -e "${VERDE}[INFO] - Script finalizado, instalação concluída! :)${SEM_COR}"
