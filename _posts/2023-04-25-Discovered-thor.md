---
layout: post
tags: [programming, cli]
excerpt_separator: "\n\n"
---

A Ruby library allowing to easily create command line tool.

Today I discovered [Thor](http://whatisthor.com/) with [this comment](https://www.reddit.com/r/ruby/comments/2omroo/comment/cmonpdd/?utm_source=share&utm_medium=web2x&context=3) on Reddit.

It is super easy to install, just run:
`gem install thor`

Then to use it, simple command line tool:
```ruby
#!/bin/ruby

require 'thor'

class SayHello < Thor
    desc "greet [NAME]", "greet using [NAME]"
    def greet(name)
        puts "Hi #{name} !"
    end

    # without this it shows an ugly warning on error
    def self.exit_on_failure?
      true
    end
end

SayHello.start ARGV
```

If you run the script with no argument you will get:
````bash
➜ ruby /tmp/say_hello.rb
Commands:
  thor.rb greet [NAME]    # greet using [NAME]
  thor.rb help [COMMAND]  # Describe available commands or one specific command
````

If you run it with `greet` option but no argument you will get:
````bash
➜ ruby /tmp/thor.rb greet
ERROR: "thor.rb greet" was called with no arguments
Usage: "thor.rb greet [NAME]"
````

And finally if you run it as it is intended to be ran:
````bash
➜ ruby /tmp/thor.rb greet 4zv4l
Hi 4zv4l !
````

I think this is really handy and allows to create quick command line tool without worrying about writing all the `options` and `arguments` parsing etc.
It allows to directly focus on the action of the tool rather than the ~packaging~.
