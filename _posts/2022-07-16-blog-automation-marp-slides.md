---
 layout: post
 title: Automating presentations - from markdown to website
 subtitle: Blog Automation - Part 2
 series: Blog Automation
---

Like many people I'm not a big fan of PowerPoint presentations. 

There's just too much to fuss about when creating slides in a WYSIWYG editor and while Office365 at least made it _possible_ to use PowerPoint as a Linux user, it's still far from a pleasant experience. 

When I work on a presentation I generally aim for slides that are simple - just a few words or images underlining what I say - and I want creating the to be just as simple. 

> Disclaimer: This won't work for you if you're presentation style relies on fancy slides with animations, etc. 
> 
>  I've recently re-used a document of headlines meant to printed as 'slides' - something a friend very kindly described as a 'lean' approach to presentations.

# The Idea

My personal website is setup as a [GitHub Page](https://pages.github.com/) which allows
me to focus on content by turning text checked in to a GitHub repo
into a static website using [jekyll](https://jekyllrb.com/).

As [written about a while ago](https://riedmann.dev/2021/10/17/blog-automation-dev-to-posting.html) the content of my site and blog posts is simple markdown, so I'm quite used to formatting text with it.

In the past I've used [marp - the Markdown Presentation Ecosystem](https://marp.app/) to generate pdf slides from markdown.

Which has the drawback of having to get that output file to wherever I want to present my slides from - you win that one Office365.

But what if I could just write my slides in markdown, commit, push and have them available as part of my website? 

# Markdown Slides with Marp

I won't go into detail on how to create Marp slides. 

If you want to know more checkout [marp.app](https://marp.app/) and the docs on [Marpit Markdown](https://marpit.marp.app/markdown) for details. 

I've created a simple sample slide deck with three slides. The comments in the snippet should tell you what you need to know for the sake of this post.

```markdown
---
marp: true
theme: uncover 
class: invert
# Header configuring this as marp slides
# Theme and class simply defining my preferred dark theme for slides
---

<!-- A slide with a title -->
# These are some sample markdown slides

---

<!-- Three dash breaks start a new slide -->
<!-- This one just has some text and a link -->

They're created using [marp](https://marp.app/)

---

<!-- Another slide with some bullet points -->

* They're rendered from markdown to HTML using the [marp-cli docker container](https://hub.docker.com/r/marpteam/marp-cli/).

* The rendered slides are deployed as part of my website.

* This happens in a [github action](https://github.com/UnseenWizzard/unseenwizzard.github.io/blob/8d812ca33bfac4106ddf5f58512740e925c835fa/.github/workflows/render-slides.yaml).
```

## A note on Jekyll

As mentioned I'm using a GitHub page and [jekyll](https://jekyllrb.com/) for my website. 

In general [jekyll](https://jekyllrb.com/) will take the markdown files from a `_posts` directory and render them to html pages on my blog. 

[jekyll](https://jekyllrb.com/) will exclude any folders starting with an underscore from it's generated output, but it includes any other files and folders in the directory it's building. 

So to add my slides I've added a `_slides` directory to place my markdown slides in. 

And we'll use marp to render them into a `slides` directory - which means the final jekyll site will contain my slides at `{url}/slides/{filename}`.

## Generating html pages with marp-cli

Because I want to use this as part of a Github Action I'm using the [marp-cli docker container](https://hub.docker.com/r/marpteam/marp-cli/). 

To turn my slides into html I simply run in the root path of my website repo: 

```sh
 docker run -v $PWD:/home/marp/app/ -e MARP_USER="$(id -u):$(id -g)" marpteam/marp-cli:v2.0.4 -I _slides/ -o slides/
```

Mapping the current working directory into the container at `/home/marp/app` with `-v $PWD:/home/marp/app/`.

Ensuring the cli can actually write files to the folder on linux, by telling to use the current user and group with `-e MARP_USER="$(id -u):$(id -g)"`. 

And finally running the CLI with the `_slides` folder as input (`-I _slides/`) and writing output to the `slides` folder (`-o slides/`)

```sh
> docker run -v $PWD:/home/marp/app/ -e MARP_USER="$(id -u):$(id -g)" marpteam/marp-cli:v2.0.4 -I _slides/ -o slides/
[  INFO ] Converting 3 markdowns...
[  INFO ] _slides/agile-retrospective-design-patterns-short.md => slides/agile-retrospective-design-patterns-short.html
[  INFO ] _slides/agile-retrospective-design-patterns.md => slides/agile-retrospective-design-patterns.html
[  INFO ] _slides/sample-slides.md => slides/sample-slides.html
```

### Github Action

As a Github Action step the same thing can be done as:

```yml
- name: Build Slides
  uses: docker://marpteam/marp-cli:v2.0.4
  with:
    args: -I _slides/ -o slides/
  env:
    MARP_USER: root:root
```

# Pushing the rendered pages to GitHub

My website is rendered from the main branch of my github pages repository, so the files that `marp-cli` just created need to get in there. 

Of course, I could just run the `marp-cli` command after I change a slide deck and then commit and push the html page in addition to the markdown source - but I want to this to happen automatically.

## Security trumps convenience
As I don't want any random github action - or person - to push changes to my website, that main branch is protected.

Meaning any change that's not from me will need to go through a Pull Request. 
This sadly adds a manual step of approving that PR which removes some of the 'fully automatic' convenience. 

## Pushing to a branch

There's nothing special about pushing the new files using git. 

The step as defined below will use the fact that each github action run as a unique `run_id` to create a unique branch to open a PR from. 

```yml
- name: Push to Branch
  run: |
    git config user.name 'marp slides build'
    git config user.email '[my-user]@users.noreply.github.com'
    git checkout -b "slides-${{github.run_id}}"
    git commit -am "feat: Add rendered slides"
    git push --set-upstream origin "slides-${{github.run_id}}"
```

## Creating a PR

After wasting some time looking at GitHub Actions to open Pull Requests I decided to keep it simple and just use curl and [the GitHub API](https://docs.github.com/en/rest/pulls/pulls#create-a-pull-request):

```yml
- name: Open PR
  run: | 
    curl -X POST \
    -f \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: token ${{ secrets.GITHUB_TOKEN }}" \
    https://api.github.com/repos/[my-user]/[my-gh-page-repo]/pulls \
    -d '{"title":"Add rendered slides","body":"Adding rendered slides","head":"slides-${{github.run_id}}","base":"master"}'
```

Which will result in curl doing a POST request to the GitHub API, authenticated with the github token that is passed to each GitHub Action - with the payload defining the PR title/body and most importantly which branches to merge. 

The `-f` (or `--fail`) flag will ensure that curl will report a non-zero (failure) exit code if the HTTP call failed - which in turn results in the GitHub action showing as failed if something goes wrong. 

# The Result

Putting it all together the full Action - configured to only run when changes to the `_slides` are pushed, and first checking out the repo - looks like this:

```yml
name: render-slides-with-marp

on:
  push:
    branches: [ master ]
    paths: 
      - "_slides/**"

jobs:
  render-slides:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Build Slides
        uses: docker://marpteam/marp-cli:v2.0.4
        with:
          args: -I _slides/ --output slides/
        env:
          MARP_USER: root:root
      - name: Push to Branch
        run: |
          git config user.name 'marp slides build'
          git config user.email '[my-user]@users.noreply.github.com'
          git checkout -b "slides-${{github.run_id}}"
          git add slides/
          git commit -m "feat: Add rendered slides"
          git push --set-upstream origin "slides-${{github.run_id}}"
      - name: Open PR
        run: | 
          curl   -X POST \
          -f \
          -H "Accept: application/vnd.github+json" \
          -H "Authorization: token ${{ secrets.GITHUB_TOKEN }}" \
          https://api.github.com/repos/[my-user]/[my-gh-page-repo]/pulls \
          -d '{"title":"Add rendered slides","body":"Adding rendered slides","head":"slides-${{github.run_id}}","base":"master"}'
```

Quite simple for allowing me to create slide decks in markdown and the simply opening my website when I need them for a presentation.

You can find the slides rendered from the sample above at [riedmann.dev/slides/sample-slides.html](https://riedmann.dev/slides/sample-slides.html).