#!/bin/sh
DISC_DEVICE="${1}"
DESTINATION="${2}"
mkdir "$DESTINATION"
makemkvcon -r --decrypt --directio=true mkv dev:${DISC_DEVICE} all "${DESTINATION}"
sudo eject "${DISC_DEVICE}"
