docker run --platform linux/amd64 --rm --volume="$PWD:/srv/jekyll" -p "4000:4000" -it jekyll/jekyll:4.2.0 jekyll serve --watch --force-polling
