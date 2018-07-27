#! /bin/sh

# Si le screensaver s'est declenche,
# on lance le nettoyage du compte utilisateur
do_something_when_blanked() {
    /usr/local/bin/bmlogout.sh -saver
}

do_something_when_unblanked() {
    echo "unblanked" > /dev/null
}

# Si le script est deja lance, on stoppe celui-ci
[[ `pgrep bmSaver` -ge 1 ]] && exit 0

# Boucle infinie de verification
while true; do
  case "`xscreensaver-command -time | egrep -o ' blanked|non-blanked|locked'`" in
    " blanked")     do_something_when_blanked ;;
    "non-blanked")  do_something_when_unblanked ;;
    "locked")       do_something_when_blanked ;;
  esac
  # On attend 30s avant de relancer la verification
  sleep 30
done

exit 0
