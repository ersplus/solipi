#!/bin/bash

#############################################################################################################
# Script d'installation de la borne raspberry Solipi                                                        #
# Version 1 16/02/2017                                                                                      #
#############################################################################################################

# Ajjouter l'utilisateur admpi qui sera l'administrateur de la borne
adduser admpi
# Définition du mot de passe  de l'user admpi

# Ajouter admpi aux groupe  d'administration
gpasswd -a admpi adm
# Création du groupe groupesudo pour pouvoir accèder à la configuration de la borne
groupadd groupesudo
# Creation de l'utilisateur borne
adduser borne
gpasswd -a borne groupesudo
gpasswd -d borne adm
gpasswd -d borne sudo

# Personnalisation de l'utilisateur borne
# chfn borne...


#############################################################################################################
# Installation logicielle
#############################################################################################################

# Installation dte mise à jour de Raspbian Light
apt update && apt upgrade && apt-get clean

# installation de yad depuis le dépot debian
wget http://ftp.fr.debian.org/debian/pool/main/y/yad/yad_0.38.2-1_armhf.deb
dpkg -i yad_0.38.2-1_armhf.deb

# Installation logicielle de la borne
aptitude install  xserver-xorg lightdm openbox lxpanel leafpad pcmanfm xarchiver zenity feh \
lxappearance obconf compton xscreensaver wicd-gtk gksudo clearlooks-phenix-theme numlockx \
libreoffice-writer libreoffice-l10n-fr libreoffice-gtk libreoffice-gtk3  libreoffice-style-tango \
libreoffice-help-fr hyphen-fr mythes-fr gucharmap galculator evince-gtk gpicview \
gsfonts gsfonts-other gsfonts-x11 ttf-mscorefonts-installer t1-xfree86-nonfree ttf-alee \
ttf-ancient-fonts ttf-arabeyes fonts-arphic-bkai00mp fonts-arphic-bsmi00lp fonts-arphic-gbsn00lp \
ttf-arphic-gkai00mp ttf-atarismall fonts-bpg-georgian fonts-dustin fonts-f500 fonts-sil-gentium \
ttf-georgewilliams ttf-isabella fonts-larabie-deco fonts-larabie-straight fonts-larabie-uncommon \
ttf-sjfonts ttf-staypuft ttf-summersby fonts-ubuntu-title ttf-xfree86-nonfree xfonts-intl-european \
xfonts-jmk xfonts-terminus fonts-arphic-ukai fonts-arphic-uming fonts-ipafont-mincho \
fonts-ipafont-gothic fonts-unfonts-core hplip cups-pdf xcompmgr exfat-fuse exfat-utils chromium-browser \
imagemagick pix-plym-splash rpi-chromium-mods -y

#############################################################################################################
# Configuration de la borne 
#############################################################################################################

# Autologin de la borne
printf "[SeatDefaults]/n" > /etc/lightdm/lightdm.conf.d/50-autologin.conf
printf "[SeatDefaults]/n" > /etc/lightdm/lightdm.conf.d/50-greeter.conf
# Ajout  de l'utilisateur borne  dans les groupes permettant l'autologin
groupadd -r autologin
gpasswd -a borne autologin
groupadd -r nopasswdlogin
gpasswd -a borne nopasswdlogin

# Modification de  PAM pour l'autologin
printf "auth sufficient pam_succeed_if.so user ingroup nopasswdlogin" >> /etc/pam.d/lightdm

# Modification de l'arrière plan du Greeter
BackgroundGreeter="background="
BackgroundGreeterValue="${BackgroundGreeter}/opt/solipi/images/background.png"
sed -i 's/${BackgroundGreeter}.*/${BackgroundGreeterValue}/' /etc/lightdm/lightdm-gtk-greeter.conf

#############################################################################################################
# Configuration du répertoire utilisateur
#############################################################################################################

# Fichier de démarrage de Openbox
mkdir /home/borne/.config/openbox
printf "/opt/solipi/scripts/bmCharte.sh /n /usr/bin/numlockx on /n lxpanel & /n pcmanfm --desktop & /n /opt/solipi/scripts/bmStartup/sh /n " > /home/borne/.config/openbox/autologin

#############################################################################################################
# Installation du serveru d'impression
#############################################################################################################

apt install hplip hplip-data hplip-doc hpijs-ppds hplip-gui hplip-dbg printer-driver-hpcups \
printer-driver-hpijs printer-driver-pxljr -y

# Le fichier de sortie de l'imprimante PDF dans le dossier HOME
# /etc/cups/cups-pdf.conf
# Out $(HOME)/
CupsPdfOutOld="Out $(HOME)/PDF"
CupsPdfOutValue="Out $(HOME)/"
sed -i 's/${CupsPdfOutOld}.*/${CupsPdfOutValue}/' /etc/cups/cups-pdf.conf

# Suppression de l'icone HP 
rm -rf /etc/xdg/autostart/hplip-systray.desktop
