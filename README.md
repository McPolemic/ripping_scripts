# Installation

`docker build -t ripper`

# Usage
```
docker run -it --rm --privileged -v ~/Videos:/videos -e RIP_TITLE="Movie Name" ripper
```

# Environment Variables
* RIP_TITLE -  Name of the movie/show. Required.
* RIP_TITLE_ID - The title id of the disk to rip. Optional.
  * Use -1 for the longest title.
  * When missing, it rips all titles.
* RIP_DEVICE Which device to read from when ripping.
  * Useful for multiple disk drives.

# Volumes
Creates a volume '/videos' where it stores videos. Either use Docker to bind that to a local directory (e.g. `-v ~/Videos:/videos`) or transfer files out after it's completed.

