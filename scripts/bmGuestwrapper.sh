#!/bin/bash

# Définition des variables

FILE='/opt/borne/share/charte.html'

# La fleche pour le pointeur de la souris
xsetroot -cursor_name left_ptr &

nohup xterm &

# Montre la fenêtre pour unquement la session guest
ONLYGUEST=true
for U in $(users); do
    if [ "${U%%-*}" != 'guest' ]; then
        ONLYGUEST=false
        break
    fi
done

if $ONLYGUEST && [ -x /usr/bin/zenity ]; then

zenity --text-info --title="Charte d’utilisation" --html --filename=$FILE --checkbox="En cochant cette case, je confirme avoir pris connaissance de la charte d'utilisation du réseau." 

	case $? in
		0)
			exec /usr/lib/lightdm/lightdm-guest-session "$@"
			;;
#		1)
#			zenity --info --title="Information" --text="Vous devez accepter la charte pour pouvoir utiler cette borne."
#			;;
		-1)
			zenity --error --title="Attention" --text="Une erreur est survenur."
			reboot
			;;
	esac
fi

