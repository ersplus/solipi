#! /bin/sh

[ ! -f /usr/local/bin/bmLib.sh ] && logger -p local0.crit "Impossible de trouver la bibliotheque standard. Abandon." && exit 1
. /usr/local/bin/bmLib.sh

# On recupere le fichier de configuration
# en fonction du nom utilise pour lancer ce script
src="/root/.net_log.loc"
[[ "x`basename ${0}`" = "remoteLogBackup.sh" ]] && src="/root/.net_log.src"

# Si le fichier de config n'existe pas, probleme, on arrete.
[[ ! -f ${src} ]] && pErr critical "Impossible de trouver les parametres de connexion. Abandon." && exit 1

# L'identifiant unique de la borne n'a pas ete cree lors de la mise en route.
[[ ! -f /root/.uniqID ]] && pErr critical "Impossible de trouver l'identifiant de la borne. Abandon." && exit 1
ID=`cat /root/.uniqID`

# On cree le fichier .netrc necessaire pour la connexion
\cp ${src} /root/.netrc
chmod 0600 /root/.netrc

# On recupere le nom du serveur distant
target=`cat /root/.netrc |grep machine | awk '{print $NF}'`

# On cree un identifiant unique a partir de l'adresse MAC de la borne
myID="`getUniqID`_`date +%Y%m%d`"

# On compresse les LOGs
[ -f /var/log/syslog ]  && tar cvjf /tmp/syslog.tbz /var/log/syslog
[ -f /opt/traces/connect.log ] && tar cvjf /tmp/connect.tbz /opt/traces/connect.log
[ -f /var/log/dansguardian/access.log ]  && tar cvjf /tmp/access.tbz /var/log/dansguardian/access.log

for  f in `echo syslog connect access`
do
    [ ! -f /tmp/${f}.tbz ]  && pErr critical "Impossible de trouver le fichier /tmp/${f}.tbz. Abandon." && exit 1
done    

# On envoie les archives sur le serveur distant
ftp ${target} << EOF
bin
mkdir ${ID}
cd ${ID}
put /tmp/syslog.tbz `getDateTime`_${ID}_log.tbz
put /tmp/connect.tbz `getDateTime`_${ID}_connect.tbz
put /tmp/access.tbz `getDateTime`_${ID}_access.tbz
quit
EOF

# Par securite, on detruit les fichiers temporaires
\rm -- /root/.netrc /tmp/syslog.tbz /tmp/connect.tbz

pErr fin "`basename ${0}`"
exit 0
