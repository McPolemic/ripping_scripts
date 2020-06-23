#!/bin/bash
shopt -s nullglob

WATCH_FOLDER="$1"

function total {
  ls ${WATCH_FOLDER}/**/*.mkv | wc -l
}

function current {
  ls ${WATCH_FOLDER}/**/*.mp4 | wc -l
}

TOTAL=$(total)
CURRENT=$(current)

(
while test $CURRENT != $TOTAL
do
  let PERCENTAGE="${CURRENT} * 100 / ${TOTAL}"
  echo $PERCENTAGE
  echo "XXX"
  echo "Finished: ${CURRENT}\nTotal: ${TOTAL}"
  echo "XXX"
  CURRENT=$(current)
  sleep 10
done
) | dialog --title "Transcode Progress" --gauge "" 24 80

