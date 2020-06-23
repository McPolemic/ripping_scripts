#!/bin/bash
shopt -s nullglob

cd "$1"

for mkv in *.mkv **/*.mkv; do
  echo "Checking ${mkv}..."
  DIRNAME="$(dirname ${mkv})"
  OUTPUT="${DIRNAME}/$(basename ${mkv} .mkv).mp4"
  if [ -f ${OUTPUT} ]; then
    continue
  fi
  echo "Converting ${mkv}..."

  HandBrakeCLI --preset "High Profile" -i ${mkv} -o ${OUTPUT}
done
