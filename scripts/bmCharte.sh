#!/bin/sh

# On définie le lieu de stockage de la charte
FILE=/usr/local/bin/charte

zenity --text-info \
       --title="Charte d'utilisation" \
       --filename=$FILE \
	   --html \
       --checkbox="J'ai lu et j'accepte la charte d'utilisation."

# On traite les cas d'utilisation
case $? in

# l'utilisateur a coché la case et Valider
    0)
        echo "Demarre la session"
	# next step
	;;
# L utilisateur n a pas coché la case
    1)
        echo "Stop la session!"
	;;
    -1)
        echo "une erreur innatendue est survenue."
	;;
esac
