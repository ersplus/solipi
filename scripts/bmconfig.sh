#!/bin/bash
#-*- coding: utf-8 -*-

# =========
# Fonctions
# =========

# Modification du nom de l'hote(borne)
changeHostname() {
    # Copie prealable en cas de probleme
    \cp /etc/hosts /etc/hosts_`date +%s`
    oldName=`cat /etc/hostname`

    # Fenetre graphique. On recupere le nouveau nom d'hote
    rep=$(zenity --entry --title="Nom d'hote" --text="Nouveau nom" --entry-text "Entrez un nom pour ce poste")
    if [ ! $? ];then 
        pErr notice "Aucun nom saisi, abandon."
        return 1
    else
        [ "x$rep" = "x" ] && return 1
        sed 's/'"${oldName}"'/'"${rep}"'/' < /etc/hosts > /etc/new_hosts

        # le nom d'hote est stocke a deux endroits: /etc/hosts et /etc/hostname
        \mv /etc/hosts /etc/hosts.old && \mv /etc/new_hosts /etc/hosts
        echo "${rep}" > /etc/hostname
        return 0
    fi 
}

# Modification du fond d'ecran. Veiller a deposer l'image HORS du profil
# de l'utilisateur par defaut, sinon elle sera affacee a la prochaine deconnexion!
changeBackground() {
    FILE=`zenity --file-selection --title="Choisissez une image"`
    case $? in
         0)
                fic=$(basename "$FILE")
                ext="${fic##*.}"
                fl=0
                for e in `echo png jpg xpm`
                do
                    [ "$e" = "$ext" ] && fl=1
                done
                [ $fl -eq 0 ] && exit 1
                wallDir="/usr/share/wallpapers"
                \mkdir -p ${wallDir}
                \cp "${FILE}" ${wallDir}
                [ -L ${wallDir}/background ]  && unlink ${wallDir}/background
                ln -fs ${wallDir}/${fic} ${wallDir}/background
                su - `getDefaultUser` -c "/usr/bin/feh --bg-fill ${wallDir}/background"
                ;;
         1)
                pErr notice "Aucun fichier choisi, abandon."
                return 0
                ;;
        -1)
                pErr warning "Erreur inattendue. Contactez votre administrateur."
                return 1
                ;;
    esac
    
}

# Restauration du precedent profil utilisateur 
restoreProfile() {
    user=`getDefaultUser`
    zenity --question --text "Etes vous sur de vouloir restaurer le profil?"
    if [ $? ]; then
        if [ -d /tmp/profils/dernier_profil ];then
            cp /home/${user}/.Xauthority /tmp/Xauthority_`getDefaultUser`
            \rm -rf /home/${user}
            if [ ! -d /home/${user} ];then
                \mv /tmp/profils/dernier_profil /home/${user}
                \mv /tmp/Xauthority_`getDefaultUser` /home/${user}/.Xauthority
                zenity --info --text "Restauration terminee."
            else
                zenity --error --text "Restauration echouee."
                return 1
            fi
        else
            zenity --error --text "Restauration impossible."
            return 1
        fi
    else
        return 1
    fi
}

# Sauvegarde de la configuration de l'hote(borne)
# Pour l'instant (26/05/2016), on sauvegarde tout le repertoire /etc
# Voir  pour plus tard si on peut "afiner" pour "alleger" la sauvegarde

# Pour identifier la configuration, on se sert de l'adresse MAC de la carte réseau
saveConfig() {
    ans=$(zenity --forms --title "Sauvegarde de la configuration" --text  "Parametres de sauvegarde" --add-entry "Adresse du serveur" --add-entry="identifiant" --add-entry="mot de passe")
    if [ "x$ans" != "x" ];then
        serverAddress=`echo $ans | awk -F\| '{print $1}'`
        serverLogin=`echo $ans | awk -F\| '{print $2}'`
        serverPwd=`echo $ans | awk -F\| '{print $3}'`
        echo "machine $serverAddress" > ~/.netrc
        echo "  login $serverLogin" >> ~/.netrc
        echo "  password $serverPwd" >> ~/.netrc
        chmod 0600 ~/.netrc

        # On genere un identifiant unique a partir de l'adresse MAC
        #mac="`/sbin/ifconfig eth0|grep HWaddr | awk '{print $NF}' | sed -e 's/:/_/g'`"
        mac64=`getUniqID`
        fic="config_${mac64}_last.tbz"
        tar cvjf /tmp/${fic} /etc/
        ftp -v "${serverAddress}" <<EOF
bin
put /tmp/${fic} /ftprasp/${fic}
quit
EOF
        [ ! -z ${fic} ] && [ -f /tmp/${fic} ] && \rm /tmp/${fic}
        [ -f ~/.netrc ] && \rm ~/.netrc
    fi
}

# Restauration de la configuration precedente
restoreConfig() {
    ans=$(zenity --forms --title "Restauration de la configuration" --text  "Parametres de restauration" --add-entry "Adresse du serveur" --add-entry="identifiant" --add-entry="mot de passe")
    if [ "x$ans" != "x" ];then
        serverAddress=`echo $ans | awk -F\| '{print $1}'`
        serverLogin=`echo $ans | awk -F\| '{print $2}'`
        serverPwd=`echo $ans | awk -F\| '{print $3}'`
        echo "machine $serverAddress" > ~/.netrc
        echo "  login $serverLogin" >> ~/.netrc
        echo "  password $serverPwd" >> ~/.netrc
        chmod 0600 ~/.netrc

        # On genere un identifiant unique a partir de l'adresse MAC
        mac64=`getUniqID`
        fic="config_${mac64}_last.tbz"
        ftp -v "${serverAddress}" <<EOF
bin
get /ftprasp/${fic} /tmp/${fic}
quit
EOF
        [ -f /tmp/${fic} ] && tar xvf /tmp/${fic} -C / && \rm /tmp/${fic}
        [ -f ~/.netrc ] && \rm ~/.netrc
    fi
}

# Sauvegarde des traces de connexion de la borne vers un serveur distant.
# Attention : Les parametres de connexion ne doivent en aucun cas etre accessibles simplement
remoteBkpLogs() {
    [[ ! -f /root/.net_log.src ]] &&  zenity --error --text "Impossible de trouver le fichier de configuration. Sauvegarde impossible." && return 1
    echo "07 21 * * * root [ -x /usr/local/bin/remoteLogBackup.sh ]  && /usr/local/bin/remoteLogBackup.sh 2>&1 >/dev/null" > /etc/cron.d/logbackups
}

# Sauvegarde des traces de connexion de la borne vers un serveur local
localBkpLogs() {
    [[ ! -f /root/.net_log.loc ]] &&  zenity --error --text "Impossible de trouver le fichier de configuration. Sauvegarde impossible." && return 1
    echo "07 21 * * * root [ -x /usr/local/bin/localLogBackup.sh ]  && /usr/local/bin/localLogBackup.sh 2>&1 >/dev/null" > /etc/cron.d/logbackups
    ans=$(zenity --forms --title "Sauvegarde des traces de connexion" --text  "Parametres de sauvegarde" --add-entry "Adresse du serveur" --add-entry="identifiant" --add-entry="mot de passe")
    if [ $? ];then
        serverAddress=`echo $ans | awk -F\| '{print $1}'`
        serverLogin=`echo $ans | awk -F\| '{print $2}'`
        serverPwd=`echo $ans | awk -F\| '{print $3}'`
        echo "machine $serverAddress" > /root/.net_log.loc
        echo "  login $serverLogin" >> /root/.net_log.loc
        echo "  password $serverPwd" >> /root/.net_log.loc
        chmod 0600 /root/.net_log.loc
    fi
}

# =========
# Principal
# =========
winWidth=400
winHeight=300

[ ! -f /usr/local/bin/bmLib.sh ] && logger -p local0.crit "Impossible de trouver la bibliotheque standard. Abandon." && exit 1
. /usr/local/bin/bmLib.sh

# Fenetre graphique sur les reglages de base
ans=$(zenity  --width=${winWidth} --height=${winHeight} --title "Configuration globale du poste" --list  --text "Configuration de base" --radiolist  --column "Choix" --column "Action" TRUE "Nom du poste" FALSE "WIFI" FALSE "Fond d'ecran" FALSE "Avance");

# Fenetre graphique sur les reglages avances
[[ "${ans}" = "Avance" ]] && ans=$(zenity  --width=${winWidth} --height=${winHeight} --title "Configuration globale du poste" --list  --text "Configuration avancee" --radiolist  --column "Choix" --column "Action" TRUE "Reglages imprimante" FALSE "Sauvegarde de la configuration" FALSE "Restauration de la configuration" FALSE "Filtrage et securite" FALSE "Restauration du dernier profil" FALSE "Archivage des connexions")

# Configuration de l'archivage distant des traces de connexion
[[ "${ans}" = "Archivage des connexions" ]] && ans=$(zenity  --width=${winWidth} --height=${winHeight} --title "Archivage des connexions" --list  --text "Archivage des connexions" --radiolist  --column "Choix" --column "Action" TRUE "Sauvegarde FTP local" FALSE "Sauvegarde FTP Bordeaux Metropole")

[ ! $? ] && exit 0

case ${ans} in
    "Nom du poste")
        changeHostname
        [[ ${?} -ne 0 ]] && exit 1
        ;;
    "WIFI")
        nohup /usr/bin/wicd-gtk &
        [[ ${?} -ne 0 ]] && exit 1
        ;;
    "Fond d'ecran")
        changeBackground
        [[ ${?} -ne 0 ]] && exit 1
        ;;
    "Reglages imprimante")
        user=`getDefaultUser`
        nohup su - ${user} -c "/usr/bin/hp-setup" &
        [[ ${?} -ne 1 ]] && exit 1
        ;;
    "Sauvegarde de la configuration")
        saveConfig
        [[ ${?} -ne 0 ]] && exit 1
        ;;
    "Restauration de la configuration")
        restoreConfig
        [[ ${?} -ne 0 ]] && exit 1
        ;;
    "Filtrage et securite")
        user=`getDefaultUser`
        nohup su - ${user} -c "chromium-browser http://127.0.0.1/CTadmin" &
        ;;
    "Restauration du dernier profil")
        restoreProfile
        [[ ${?} -ne 0 ]] && exit 1
        ;;
    "Sauvegarde FTP Bordeaux Metropole")
        remoteBkpLogs
        [[ ${?} -ne 0 ]] && exit 1
        ;;
    "Sauvegarde FTP local")
        localBkpLogs
        [[ ${?} -ne 0 ]] && exit 1
        ;;
esac
logger -p local0.notice "Fin normale du script de configuration"
exit 0
# =============
# Fin du script
# =============
#vim: set nu ai expandtab tabstop=4 shiftwidth=4
