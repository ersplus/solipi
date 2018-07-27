#! /bin/bash

[ ! -f /usr/local/bin/bmLib.sh ] && logger -p local0.crit 'Impossible de trouver la bibliotheque standard. Abandon.' && exit 1
. /usr/local/bin/bmLib.sh

# Creation de l'identifiant unique lors de la premiere
# mise en route de la borne
getFirstID

# On modifie le curseur X par défaut de la souris
xsetroot -cursor_name left_ptr&

# On lance le diaporama de presentation
#nohup /usr/bin/qiv -R -G --slide -St -d10 /opt/images/saver&
nohup /usr/bin/feh -D5 -Sname /opt/images/saver&

ret=1
mkdir -p /opt/traces
# On nettoie le compte de l'utilisateur precedent
[ -x /usr/local/bin/cleanHomedir.sh ]  && /usr/local/bin/cleanHomedir.sh

# On boucle sur la fenetre d'identification jusqu'a ce qu'un
# identifiant "correct" ai ete saisi
while [ $ret -eq 1 ]; do
	ans=$(zenity  --forms --title "Connexion" --text  "Connexion" --add-entry "Prenom" --add-entry="Nom")
	ret=$?
	if [ $ret -eq 0 ];then
        #Si l'identifiant convient, on arrete la presentation
#        pkill qiv
        pkill feh

        # On recupere les infos saisies par l'utilisateur
        # et on les place dans des fichiers de "trace"
		userFirst=`echo $ans | awk -F\| '{print $1}'`
		userLast=`echo $ans | awk -F\| '{print $2}'`
		[ "x$userFirst" = "x" ] && ret=1
		[ "x$userLast" = "x" ] && ret=1
		if [ $ret -eq 0 ];then
			echo "`date +%Y%m%d_%H%M%S`:${userFirst}:${userLast}" >> /opt/traces/connect.log
			echo "`date +%Y%m%d_%H%M%S`:${userFirst}:${userLast}" > /home/${NODM_USER}/.connect.log
			exit 0
		fi
	fi
done
exit 0
