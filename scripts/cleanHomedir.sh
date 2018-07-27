#! /bin/bash

# =========
# Principal
# =========

# On charge une bibliotheque de fonctions commune
[ ! -f /usr/local/bin/bmLib.sh ] && logger -p local0.crit "Impossible de trouver la bibliotheque standard. Abandon." && exit 1
. /usr/local/bin/bmLib.sh

# On recupere dans le fichier de conf de lightdm le compte de connexion par defaut
defaultUser=`getDefaultUser`

# Si le "homedir" n'existe pas: probleme, on arrete
[ ! -d "/home/${defaultUser}" ]  && logger -p local0.crit "HOMEDIR de ${defaultUser} introuvable. Abandon." && exit 1

atDate=`getDateTime`
mkdir -p /tmp/profils
arc="/tmp/profils/dernier_profil"
[ -d ${arc} ] && \rm -rf ${arc}
mv /home/${defaultUser} ${arc}

# Si l'archive contenant les fichiers par defaut n'existe pas: Probleme, on arrete
cleanProfile="/opt/profil/profil_orig.tar"
[ ! -f ${cleanProfile} ] && logger -p local0.crit "Impossible de trouver l'archive de reference!" && exit 1

# On efface le homedir
[ -d "/home/${defaultUser}" ] && \rm "/home/${defaultUser}"

# On decompresse l'archive "squelette"
tar xvf ${cleanProfile} -C /home

# On redonne les droits de l'utilisateur
chown -R ${defaultUser}:${defaultUser} "/home/${defaultUser}"

# Pour indiquer qu'on a bien nettoye le compte
touch /tmp/${defaultUser}_cleaned
exit 0
# =============
# Fin du script
# =============
