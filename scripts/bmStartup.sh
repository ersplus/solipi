#! /bin/bash

# On lance le screensaver
/usr/bin/xscreensaver -nosplash&

# On lance le script de verification
# du verrouillage de l'ecran
nohup /usr/local/bin/bmSaver.sh&

exit 0
