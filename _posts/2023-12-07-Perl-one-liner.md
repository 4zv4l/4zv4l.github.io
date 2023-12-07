---
layout: post
tags: [programming, linux, cli]
excerpt_separator: "\n\n"
---

Today I had to add a list of users to a service (`knowbe4`).
I could have done it manually but I decided to use Perl to do it which (I think) made me gain a lot of time.

Instead of checking the current subscribed users, see which one to delete and which one to add manually (would have taken a lot of time since there are a lot of users already and even more users to add).

The format for `to_add.csv` was like this:
```csv
First Name,Second Name,Email Address
```

So here I share the one liner I came up with:
```sh
perl -ne 'chomp;/,([^,]+)$/;$#ARGV==0 ? $keep{lc $1}=$_ :exists $keep{lc $_} ? print $keep{lc $_},"\n" : warn $_, "\n"' to_add.csv already_in_mail 1>test_keep.csv 2>test_remove.csv
```

Here is how it works:
- `perl -ne` will read the files given in argument line by line (equivalent of `while (<>)`)
- `chomp` remove the newline from the line
- `/,([^,]+)$/` apply the regex to the line and capture the first group (mail address) into `$1`
- `$#ARGV==0` check if its the first file given so `to_add.csv`
- if yes: `$keep{lc $1}=$_` put the current line into a hash array and the mail is the key
- if not: `exist $keep{lc $_}` check if the mail exist
- if yes: it means we need to add/keep the mail to the service
- if not: (the mail is not in the to_add file) then we need to remove it
I used `print` and `warn` to differentiate, so I redirect `stdout` for the user to add and `stderr` for the user to remove in their respective file.