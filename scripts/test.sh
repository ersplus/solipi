#!/bin/bash

# Définition des variables

FILE='/opt/borne/share/charte.html'

# Montre la fenêtre pour unquement la session guest

if $ONLYGUEST && [ -x /usr/bin/zenity ]; then

zenity --text-info --title="Charte d’utilisation" --html --filename=$FILE --checkbox="J’accepte la charte" 

	case $? in
		0)
			exec /usr/lib/lightdm/lightdm-guest-session "$@"
			;;
		1)
			zenity --info --title="Information" --text="Vous devez accepter la charte pour pouvoir utiler cette borne."
			;;
		-1)
			zenity --error --title="Attention" --text="Une erreur est survenur."
			;;
	esac
fi

