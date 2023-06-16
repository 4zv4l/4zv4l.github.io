---
layout: post
tags: [programming, web]
excerpt_separator: "\n\n"
---

A Ruby library allowing to easily create static website (like this one).

Today I discovered [Jekyll](https://jekyllrb.com/) with [this comment](https://www.reddit.com/r/ruby/comments/2omroo/comment/cmonpdd/?utm_source=share&utm_medium=web2x&context=3) on Reddit.

To install and run `jekyll` simply do:
```bash
➜ gem install bundler jekyll

➜ jekyll new my_blog

➜ cd my_blog

➜ bundle exec jekyll serve

# => Now browse to http://localhost:4000 
```

To add `posts` you can simply add a new `mardown` file:
```bash
➜ cd _posts
➜ touch > 2023-04-25-my-super-title.md
```
- the filename format is `YEAR-MONTH-DAY-title.EXT`

Example of post (this one actually):
```````md
---
layout: post
tags: [programming]
excerpt_separator: "\n\n"
---

A Ruby library allowing to easily create static website (like this one).

Today I discovered [Jekyll](https://jekyllrb.com/) with [this comment](https://www.reddit.com/r/ruby/comments/2omroo/comment/cmonpdd/?utm_source=share&utm_medium=web2x&context=3) on Reddit.

To install and run `jekyll` simply do:
```bash
➜ gem install bundler jekyll

➜ jekyll new my_blog

➜ cd my_blog

➜ bundle exec jekyll serve

# => Now browse to http://localhost:4000 
```

To add `posts` you can simply add a new `mardown` file:
```bash
➜ cd _posts
➜ echo -e "---\nlayout: post\n---\n" > 2023-04-25-my-super-title.md
```
- the filename format is `YEAR-MONTH-DAY-title.EXT`

To customize the configuration you can edit `_config.yml`:
```yml
title: your website title
email: your@email.com
description: website description
author:
  name: your author name
github_username: github username
plugins: # your plugins
  - jekyll-paginate
  - jekyll-remote-theme
remote_theme: chesterhow/tale # use tale them with the plugin
paginate: 5 # 5 posts per page (homepage listing posts)
permalink: /:year-:month-:day/:title.html # posts format on the website
```

To add themes I suggest you to go [here](https://jekyllrb.com/docs/themes/).

And that makes a really easy to setup static website to make your own blog !
```````

To customize the configuration you can edit `_config.yml`:
```yml
title: your website title
email: your@email.com
description: website description
author:
  name: your author name
github_username: github username
plugins: # your plugins
  - jekyll-paginate
  - jekyll-remote-theme
remote_theme: chesterhow/tale # use tale them with the plugin
paginate: 5 # 5 posts per page (homepage listing posts)
permalink: /:year-:month-:day/:title.html # posts format on the website
```

To add themes I suggest you to go [here](https://jekyllrb.com/docs/themes/).

And that makes a really easy to setup static website to make your own blog !
