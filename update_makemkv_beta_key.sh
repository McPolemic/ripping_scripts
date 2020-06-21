#!/bin/bash
CODE=$(curl -Ls 'http://makemkv.com/forum2/viewtopic.php?f=5&t=1053' | grep -oP '<code>[^<]+' | cut -d '>' -f 2-)

echo "Update ~/.MakeMKV/settings.conf with "
echo "app_Key = \"${CODE}\""
