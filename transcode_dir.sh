#!/bin/sh
cd "$1"
for mkv in *.mkv; do
  OUTPUT="$(basename ${mkv} .mkv).mp4"
  HandBrakeCLI --preset "High Profile" -i ${mkv} -o ${OUTPUT}
done
