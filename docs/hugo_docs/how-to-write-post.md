# How to write hugo blog posts
How to write a blog post on the matabit-blog. 

## Requirements 
* Hugo
* Matabit-blog repo
* Hyde-hyde git submodule added

## Feature branching post
Be sure to create a new branch for your blog post using `git checkout -b name-of-your-branch`

## Generating a new blog post
In order to generate the boilerplate for a new blog post, run `hugo new posts/[postname].md` in the root directory of the hugo blog
repository


## Configuring the Front Matter YAML
When you generate the posts using the `hugo new posts/[postname].md` a markdown file will be created in the `contents/posts`
directory. Open the markdown file you've create with your favorite text editor like vim, vscode, etc and you'll see.

```yaml
---
title: "Example post"
date: 2018-08-28T23:15:05-07:00
draft: true
---
```

Change the front matter to set `draft: false` and add `layout: posts`. Setting the layout to posts allows the theme to properly 
display as one of the post templates. After the front matter, signified by the last `---`, add your content using the Markdown syntax
```yaml
---
title: "Example post"
date: 2018-08-28T23:15:05-07:00
layout: 'posts'
draft: false
---
# This is a sample post
With some sample content
```

## Serving the site locally
You can run `hugo serve` in the root directory of the project to view a live demo of the site. This also includes live reloading
to view your site as you make changes. This is useful to view spelling or to preview the page before building it.

## Building the page
After you are satisified with your post in the markdown file it is time to generate the site. Simple run `hugo` in the root directory
and watch the magic as hugo transforms your markdown into HTML/CSS/JS. The output of the hugo command will be in a directory called
`public/`. **Don't forget to push your changes to Github!** Also create a pull request to be merged into master.
At this point you can deploy the site. From here you can point your webserver to the `public/` directory or follow our deploy guide.
