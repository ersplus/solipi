#! /bin/bash

# =========
# Principal
# =========

# Creation du repertoire des profils 
# au cas ou il n'existerait plus
mkdir -p /tmp/profils

# Si ce script est lance par le screensaver
# on n'affiche pas de fenetre de confirmation
if [ "x${1}" != "x-saver" ];then
    ans=$(zenity  --title "*!!! Fermeture de session !!!*" --text "ATTENTION: Tout fichier non sauvegardé sur un support externe (clef USB) sera définitivement PERDU!" --question)
    RET=${?}
else
    RET=0
fi    

# On tue le process de surveillance 
# et on arrete l'interface (openbox)
if [[ ${RET} -eq 0 ]];then
    pkill bmSaver
    pkill xscreensaver
    openbox --exit
fi
exit 0
# ================
# Fin du programme
# ================
