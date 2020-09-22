#!/bin/bash

if [ -z "$RIP_TITLE" ]; then
  echo "Missing required environment variable RIP_TITLE"
  cat <<EOF
    ENVIRONMENT VARIABLES:
    * RIP_TITLE           Name of the movie/show. Required.
    * RIP_TITLE_ID        The title id of the disk to rip. Optional.
                          Use -1 for the longest title.
		                      default: all titles
    * RIP_DEVICE          Which device to read from when ripping.
                          Useful for multiple disk drives.
    * TRANSCODE_PRESET    Which preset should to use from HandBrakeCLI.

    Creates a volume '/videos' where it stores videos. Either use Docker to
    bind that to a local directory (e.g. '-v ~/Videos:/videos') or transfer
    files out after it's completed.
EOF
  exit 1
fi

./rip_disk.rb && ./transcode_dir.rb "$RIP_TITLE"
