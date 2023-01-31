#!/bin/bash

ruby recurse_folders.rb  | egrep -v 'DISPLAY|Pick|Consuetudo|Organizatio' | while read ORG foo bar; do 
	echo ruby recurse_folders.rb "$ORG"
done


echo 'if you like it, call again with "| xargs sh" (tranquillo, this is in stderr)' 1>&2