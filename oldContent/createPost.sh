#!/bin/bash
TODAY=`date +%Y-%m-%d`
FILENAME=./_posts/$TODAY-$1.md

touch $FILENAME
echo -e "---\nlayout: post\ntitle: $1\ndate: $TODAY\n---\n" > $FILENAME


vim $FILENAME

echo "Created post: $FILENAME"


