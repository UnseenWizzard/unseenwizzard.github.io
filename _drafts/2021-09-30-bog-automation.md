--- 
 layout: post 
 title: Blog Automation 
 subtitle: Posting to dev.to
---

# Using git to detect new blog posts

```
> git diff-tree --name-status -r HEAD 
a27c7f01026bdd1408ac9a256efc05f8b357b119
M	_posts/2019-06-02-git.md
A	_posts/2021-09-30-test.md


> git diff-tree --name-status -r HEAD | sed -n -e 's/A\s*\(.*\)/\1/p' 
_posts/2021-09-30-test.md

# Posting to the dev.to 


## Forem API

...

wiremock

```
FROM openjdk:8-alpine
RUN mkdir wiremock
WORKDIR wiremock
RUN wget https://repo1.maven.org/maven2/com/github/tomakehurst/wiremock-jre8-standalone/2.28.0/wiremock-jre8-standalone-2.28.0.jar
COPY mappings mappings
CMD ["java", "-jar", "wiremock-jre8-standalone-2.28.0.jar", "--local-response-templating", "--verbose"]

----
mappings/article-api.json
{
    "request": {
        "method": "POST",
        "url": "/articles"
    },
    "response": {
        "status": 200
    }
}


--- test data
{ "published": false, "body_markdown": "--- \n layout: post \n title: An automation test\n subtitle: a test subtitle\n---\n\n# Test content\n"}
```


# Putting it together

curl localhost:8080/articles -d '{ "published": false, "body_markdown": "\
$(\ 
git diff-tree --name-status -r HEAD | \
sed -n -e 's/A\s*\(.*.md\)/\1/p' | \
xargs cat \
) " }'


curl -X POST localhost:8080/articles \
-H 'Content-Type: application/json' \
-H 'api-key: KEY' \
-d "{ \"published\": false, \"body_markdown\": \" $(git diff-tree --name-status -r HEAD | sed -n -e 's/A\s*\(.*.md\)/\1/p' | xargs cat) \" }" 

curl -X POST https://dev.to/api/articles \
-H 'Content-Type: application/json' \
-H 'api-key: KEY' \
-d "{ \"published\": false, \"body_markdown\": \" $(git diff-tree --name-status -r HEAD | sed -n -e 's/A\s*\(.*.md\)/\1/p' | xargs cat) \" }" 

```

