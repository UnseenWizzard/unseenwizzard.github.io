#!/bin/bash
FILENAME=./_posts/$1-01-01-$2.md
touch $FILENAME
echo -e "--- \n layout: null \n title: $1 \n subtitle: $2\n image: \"img/timeline/default.jpg\" \n---\n" > $FILENAME
vim $FILENAME
echo "Created post: $FILENAME"