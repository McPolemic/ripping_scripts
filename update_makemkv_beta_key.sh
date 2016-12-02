#!/bin/bash
curl -s 'http://makemkv.com/forum2/viewtopic.php?f=5&t=1053' | grep -oP '<div class="codecontent">\K[^<]+'
