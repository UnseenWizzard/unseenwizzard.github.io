---
 layout: post
 title: How I automated publishing my personal blog posts to dev.to
 subtitle: Blog Automation - Part 1
 series: Blog Automation
---

I've recently decided to start writing again.

And like most engineers I've immediately got down to... updating my website to
contain a blog, and automating things like posting to other sites like dev.to.

So to at least get _some_ writing done and share a bit of my workflow, here's
how I've automated posting to dev.to using Github Actions.

# The Idea

My personal website is setup as a [GitHub Page](https://pages.github.com/) which allows
me to focus on content by turning text checked in to a GitHub repo
into a static website using [jekyll](https://jekyllrb.com/).

Given that my blogposts are already written in markdown and dev.to offers an API that accepts
markdown, publishing new posts to my personal website as well as dev.to seems easy.

Simply take any new blog posts pushed to the GitHub repo, and send them to the dev.to API in addition to rendering my
website.

![](https://riedmann.dev/img/blog-automation/blog_automation_overview.svg)
> image created with [Excalidraw](excalidraw.com) and the [Dev Ops Icons](https://libraries.excalidraw.com/?target=_excalidraw&referrer=https%3A%2F%2Fexcalidraw.com%2F&useHash=true&t[oken=WP8NRfaPj79aLbcdlm8CN&theme=light&sort=default#markopolo123-dev_ops) library by [Mark Sharpley](https://www.marksharpley.co.uk/)

And because it seems so easy and I like things simple I've decided to make this work on my own using just Unix tools, git and curl instead of using an existing [GitHub Action](https://github.com/features/actions).

# Finding new Blog Posts

For the initial version of this I'm only interested in finding newly added blog posts on the main
branch of my GitHub repo.

Let's say the latest commit on the main branch was `aaaaaaa` and I've just added two new posts and modified an old one in `bbbbbbb`.

## Just a `git diff`

A simple `git diff aaaaaaa bbbbbbb` will show us the changes the between these two commits.

But that's way to much, because all we care about are the type of modification and filename.

Which `diff` can luckily give us with a flag:

```sh
git diff --name-status aaaaaaa bbbbbbb
M	_posts/2019-06-02-modified.md
A	_posts/2021-09-30-added.md
A	_posts/2021-10-17-added.md
```

Great! One **M**odified file and two **A**dded files in `_posts/`.

But we still need to get this down to just the paths to new posts.

## `sed` to the Rescue

To filter this down to just the filepaths of added posts, we'll use one of the more daunting Unix tools, the stream editor [sed](https://www.gnu.org/software/sed/manual/sed.html).

We'll use it with a simple regex to transform the output of `git diff` into a list of newly added blog posts:

```sh
sed -n -e 's/A\s*\(_posts\/.*.md\)/\1/p'
```

Simple right? Let's quickly run through that line:

`-n` tells `sed` to be 'silent'.

`sed` operates per line, reading a line, performing operations and then printing/returning the edited line - unless told to be silent, which makes it print nothing unless told otherwise.

The `p` at the end of our commands tells it to print when the pattern was matched.


`-e` simply tells `sed` explicitly that the next part is a command. We could ommit this.

The **s**ubstitution command that follows is the intersting part. It follows this format:

```sh
s/[pattern to replace]/[what to replace it with]/[options]
```

Let's disect how ours turns the input into just outputting the paths to any added files:

```
s/A\s*\(_posts\/.*.md\)/\1/p`

> s/

Substitution command

> A\s*\(_posts\/.*.md\)

A         - lines starting with 'A'
\s*       - followed by zero or more whitespaces
_posts\/  - followed by '_posts/'
.*        - followed by zero or more characters
.md       - ending in .md
\(...\)   - captures what is between the braces to use again later

> \1

Simply references the content of the first capture group - the content of the braces above, which is our filepath.

> /p

Print the output of the substition command.
```

Putting `git` and `sed` together with a pipe (`|`), we get what we need:

```sh
git diff --name-status aaaaaaa bbbbbbb | sed -n -e 's/A\s*\(_posts\/.*.md\)/\1/p'
_posts/2021-09-30-added.md
_posts/2021-10-17-added.md
```

# Posting to dev.to

Now that we have the markdown files of new posts, it's time to send them to dev.to.

## Forem API
dev.to uses [forem](https://www.forem.com/) which offers a straight forward [articles API](https://developers.forem.com/api#operation/createArticle) that accepts markdown with typical frontmatter directly.

So in theory we can POST the contents of our markdown files straight to dev.to.

### Wiremock for testing API integrations

To test this - or any API - locally, [wiremock](wiremock.org.) is a great tool.

In standalone mode it can be run as a jar directly or using the [docker container](https://hub.docker.com/r/wiremock/wiremock/), and be configured using JSON to offer the endpoints you need and return what you want for testing.

To test the basics of integrating with the forem API we'll do the following:

Start the wiremock docker container in **v**erbose mode, mapping it's default `8080` port to the same port on our system.

```sh
docker run -p 8080:8080 wiremock/wiremock:latest -v
```

And then define a simple version of the articles API by sending it to the wiremock instance.

For this we use `curl` to call wiremock's API with JSON **d**ata modelling the API endpoint we want to mock:

```sh
curl localhost:8080/__admin/mappings/new -d\
'{
    "request": {
        "method": "POST",
        "url": "/api/articles"
    },
    "response": {
        "status": 200
    }
}'
```

Now `localhost:8080/api/articles` will accept POST requests and always return a HTTP 200 response.

Not really realistic, but a good start for testing, and seeing what payload arrives at the API, thanks to wiremock priting all calls it receives in verbose mode.

## POSTing Blog Posts

To try out the local mock API we can send it a test payload:

```sh
curl localhost:8080/api/articles -d '{"article": { "published": false, "body_markdown": "--- \n layout: post \n title: An automation test\n subtitle: a test subtitle\n---\n\n# Test content\n"} }'
```

This will POST an `article` object - which could be completely defined with just it's `body_markdown` as that already contains required information like the title, etc. in it's frontmatter.

But as I want to be able to give posts a final look, the payload also includes `"published": false` so posts will be created as a draft that can be published manually.

# Putting it all together

## `git` + `sed` + `curl` = `profit`

Time to put it all together, which I've done in a simple shell script:

```sh
#!/bin/sh

url=$URL
api_key=$API_KEY

echo "Detecting files added between commits $1 and $2..."

new_files=`git diff --name-status $1 $2 | sed -n -e 's/A\s*\(_posts\/.*.md\)/\1/p'`

for f in $new_files; do
    echo "Creating dev.to article for $f..."

    echo '{"article": { "published": false, "body_markdown": "' > api_payload
    sed -e ':a;N;$!ba;s/\n/\\n/g' $f >> api_payload
    echo '" }}' >> api_payload

    curl $url \
        -H 'Content-Type: application/json' \
        -H "api-key: $api_key" \
        -d @api_payload \
        -v

    rm api_payload
done
```

There's a few more steps than just `git`, `sed` and `curl` in there, so let's quickly run through them.

The scripts will get the `URL` and dev.to `API_KEY` from environment variables, so they can be passed in from a GitHub Action.

```sh
url=$URL
api_key=$API_KEY
```

Then it will find any `new_files` between two commits that are passed in as first and second input arguments (`$1` and `$2`), and then post the content to the given `URL` for each of the `new_files`.

```sh
new_files=`git diff --name-status $1 $2 | sed -n -e 's/A\s*\(_posts\/.*.md\)/\1/p'`

for f in $new_files; do
```

The body of the HTTP POST is placed in a temporary `api_payload` file - but could also be built in place, or one long command piping into `curl`.

```sh
echo '{"article": { "published": false, "body_markdown": "' > api_payload
sed -e ':a;N;$!ba;s/\n/\\n/g' $f >> api_payload
echo '" }}' >> api_payload
```

The only really interesting part of creating the payload is `sed -e ':a;N;$!ba;s/\n/\\n/g' $f >> api_payload`.

`sed` is used here to replace any newline in the markdown file with an escpaded newline `\\n`, so that the payload will actually contain `\n` characters for each line break.
Without this the API call would swallow all newlines and the blog post on dev.to would miss all linebreaks.

How exactly that `sed` expression replaces characters in the whole file is nicely described in [this stakeoverflow post](https://stackoverflow.com/a/1252191), so I will not repeat it here.

`curl` simply sends the json content of the temporary `api_payload` file to the given `URL` using the `API_KEY`.

```sh
curl $url \
    -H 'Content-Type: application/json' \
    -H "api-key: $api_key" \
    -d @api_payload \
    -v
```

## GitHub Action

Now to have this script run whenever I add a new blog post to my website repo, we're still missing a GitHub action that calls it:

```yaml
name: post-to-dev-to

on:
  push:
    branches: [ master ]
    paths:
      - "_posts/**"

jobs:
  post-to-dev:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
        with:
        fetch-depth: 0
      - name: post
        run: .github/workflows/dev-post.sh ${{ github.event.before}} ${{github.event.after}}
        env:
          URL: https://dev.to/api/articles
          API_KEY: ${{ secrets.DEV_TO_KEY }}
```

Because posting to dev.to should only happen for new posts I've pushed to the main branch of the repo, the Action is configured to only trigger if the `_posts/` folder changes after a push to `master`.

```yaml
on:
  push:
    branches: [ master ]
    paths:
      - "_posts/**"
```

Then the Action excutes one job on an ubuntu container, in which it first makes sure the repo is checked out, and then executes our script from above.

```yaml
jobs:
  post-to-dev:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: post
        run: .github/workflows/dev-post.sh ${{ github.event.before}} ${{github.event.after}}
        env:
          URL: https://dev.to/api/articles
          API_KEY: ${{ secrets.DEV_TO_KEY }}
```

To execute the script is uses information from the `github.event` that triggered the Action to get the latest commit `before` and `after` the push happened.

# What's next?

You're hopefully reading this on dev.to, proving this first part of blog automation has worked.

If this is actually interesting to anyone I'll continue the series with a writeup on how I use markdown and GitHub actions to also create and publish slide-decks.

Else I'll just continue my personal mission of only ever having to write markdown and wasting time on automation quitely and go back to writing about other things.