#!/bin/sh

url=$URL
api_key=$API_KEY

echo "Detecting files added between commits $1 and $2..."

new_files=`git diff --name-status $1 $2 | sed -n -e 's/A\s*\(_posts\/.*.md\)/\1/p'`

for f in $new_files; do
    echo "Creating dev.to article for $f..."

    echo -n '{"article": { "published": false, "body_markdown": "' > api_payload
    sed -e ':a;N;$!ba;s/\(["\\]\)/\\\1/g;s/\n/\\n/g;s/\t/  /g' $f >> api_payload
    echo -n '" }}' >> api_payload

    curl $url \
        -H 'Content-Type: application/json' \
        -H "api-key: $api_key" \
        -d @api_payload \
        -v

    rm api_payload
done