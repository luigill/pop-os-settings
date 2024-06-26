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

# ----------------------------- VARIÁVEIS ----------------------------- #
set -e


##URLS

URL_OBSIDIAN="https://github.com/obsidianmd/obsidian-releases/releases/download/v1.5.12/obsidian_1.5.12_amd64.deb"
URL_CODIUM="https://github.com/VSCodium/vscodium/releases/download/1.89.1.24130/codium_1.89.1.24130_amd64.deb"
URL_APPIMAGELAUNCHER="https://github.com/TheAssassin/AppImageLauncher/releases/download/v2.2.0/appimagelauncher_2.2.0-travis995.0f91801.bionic_amd64.deb"
URL_FASTFETCH="https://github.com/fastfetch-cli/fastfetch/releases/download/2.14.0/fastfetch-linux-amd64.deb"

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
	timeshift
	vlc
	git
	wget
	build-essential
	gnome-tweaks
  gcc
  eza
  bat
)

# ---------------------------------------------------------------------- #

## Download e instalaçao de programas externos ##

install_debs() {

	echo -e "${VERDE}[INFO] - Baixando pacotes .deb${SEM_COR}"

	mkdir "$DIRETORIO_DOWNLOADS"
	wget -c "$URL_OBSIDIAN" -P "$DIRETORIO_DOWNLOADS"
	wget -c "$URL_CODIUM" -P "$DIRETORIO_DOWNLOADS"
	wget -c "$URL_APPIMAGELAUNCHER" -P "$DIRETORIO_DOWNLOADS"
	wget -c "$URL_FASTFETCH" -P "$DIRETORIO_DOWNLOADS"
	

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

    flatpak install flathub com.discordapp.Discord -y
    flatpak install flathub com.brave.Browser -y
    flatpak install flathub com.spotify.Client -y
    flatpak install flathub net.lutris.Lutris -y
    flatpak install flathub com.heroicgameslauncher.hgl -y
    flatpak install flathub net.davidotek.pupgui2 -y
    flatpak install flathub com.obsproject.Studio -y
    flatpak install flathub org.qbittorrent.qBittorrent -y
    flatpak install flathub com.bitwarden.desktop -y
    flatpak install flathub md.obsidian.Obsidian -y
    flatpak install flathub io.freetubeapp.FreeTube -y
    flatpak install flathub com.stremio.Stremio -y
    flatpak install flathub com.github.johnfactotum.Foliate -y
    flatpak install flathub com.rafaelmardojai.Blanket -y
    flatpak install flathub com.protonvpn.www -y
    flatpak install flathub info.febvre.Komikku -y
}

add_aliases(){

    echo -e "${VERDE}[INFO] - Adicionando os aliases${SEM_COR}"

    echo 'alias p3="python3"' >> ~/.bashrc
    echo 'alias nf="fastfetch"' >> ~/.bashrc
    echo 'alias up="sudo apt update && sudo apt upgrade -y && flatpak update -y && sudo apt autoremove -y"' >> ~/.bashrc
    echo 'alias ls="eza --icons"' >> ~/.bashrc
    echo 'alias la="eza --icons -l"' >> ~/.bashrc
    echo 'alias cat="bat"' >> ~/.bashrc
}

install_mise(){

    echo -e "${VERDE}[INFO] - Instalando mise${SEM_COR}"

    curl https://mise.run | sh
    echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc
    eval "$(~/.local/bin/mise activate bash)"
    ~/.local/bin/mise --version
    mise use --global node@20
    mise use --global python@3.11
}

install_starship(){

    echo -e "${VERDE}[INFO] - Instalando starship${SEM_COR}"

    curl -sS https://starship.rs/install.sh | sh
    echo 'eval "$(starship init bash)"' >> ~/.bashrc
}


install_papirus(){

    echo -e "${VERDE}[INFO] - Instalando icons papirus${SEM_COR}"

    wget -qO- https://git.io/papirus-icon-theme-install | sh
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
add_aliases
install_mise
install_papirus
install_starship
extra_config
apt_update
system_clean

## finalização

echo -e "${VERDE}[INFO] - Script finalizado, instalação concluída! :)${SEM_COR}"