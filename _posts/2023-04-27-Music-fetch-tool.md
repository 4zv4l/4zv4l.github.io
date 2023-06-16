---
layout: post
tags: [programming]
excerpt_separator: "\n\n"
---

Presenting my two scripts to manage my music collection.

I used to run `cmus` in my terminal as music player, but after a while it started to get really slow when I got lot of musics.  
So I decided to try something else, that's how I found [ncmpcpp](https://github.com/ncmpcpp/ncmpcpp).  
It is a music player that is a client of the `MPD` (Music Player Daemon) server.

I have a very basic system to handle my music which is a simple script that allows me to:
- add music
- delete music
- upload music to the server
- download music from the server

My server is more like a backup than something else here.

Here is the bash script I made before:
```bash
#!/bin/bash

dir="$HOME/Music/mine"
srv="homelab:/DATA/Media/Musics"
txtgrn='\e[0;32m' # Green
txtwht='\e[0;37m' # White

add() {
  [ "$1" = "" ] && echo "no url given" && exit 1
  url="$1"
  echo -e "${txtgrn}Downloading" "$txtwht" "$url"
  yt-dlp --extract-audio "$url" 2> /dev/null
  music=$(ls ./*.opus)
  echo -e "${txtgrn}Converting" "$txtwht" "$music"
  ffmpeg -i "$music" "${music%%.opus}.mp3" 2> /dev/null
  echo -e "${txtgrn}Deleting" "$txtwht" "$music"
  rm "$music"
  echo -e "${txtgrn}Moving" "$txtwht" "${music%%.opus}.mp3"
  mv "${music%%.opus}.mp3" "$dir"
}

rem() {
  del="$(find "$dir" -type f | fzf)"
  echo -e "${txtgrn}Deleting" "$txtwht" "$del"
  rm "$del"
}

sync() {
  [ "$1" = "" ] && echo "no action given" && exit 2
  action="$1"
  case "$action" in
    "get") scp -r "$srv/*" "$dir/.." ;;
    "give") scp -r "$dir/" "$srv" ;;
    *) echo "not right action" && exit 3
  esac
}

usage() {
  echo "
usage: ${0##*/} [OPTION]

OPTIONS:
  play            start the music player
  add  [url]      download a music and add it to the library
  rem             remove a music from library
  sync [get/give] synchronize between client and server"
}

[ $# -lt 1 ] && usage && exit 0
case "$1" in
  "play") ncmpcpp ;;
  "add") add "$2" ;;
  "rem") rem ;;
  "sync") sync "$2" ;;
  *) echo "$1: unknown option";;
esac
```
- it is not very pretty
- I messed a lot with the `scp` part
- but it works fine

But after I [discovered thor](/2023-04-25/Discovered-thor.html) which allows to make nice command line tools easily, I decided to rewrite it in `ruby`.  
Here is how it looks:
```ruby
#!/bin/ruby

require 'thor'
require 'fileutils'
require 'net/ssh'
require 'net/scp'

MUSICS = File.expand_path "~/Music/Musics"

class Ydl < Thor
  descs = {
    play:   ["play",            "start the music player"],
    search: ["search",          "search for music in the library"],
    add:    ["add  [URL]",      "add music from URL"],
    rem:    ["rem",             "remove music by name using fzf"],
    sync:   ["sync [get/give]", "sync the music with the server"]
  }

  desc(*descs[:play])
  def play
    exec("ncmpcpp")
  end

  desc(*descs[:search])
  def search
    `ls #{MUSICS} | fzf`.chomp
  end

  desc(*descs[:add])
  def add(url)
    `yt-dlp -x --audio-format mp3 #{url}`
    file = `ls *.mp3`.chomp
    mp3 = "#{File.basename(file, File.extname(file))}.mp3"
    FileUtils.mv(mp3, MUSICS)
  rescue => e
    abort "couldn't download the music: #{e}"
  end

  desc(*descs[:rem])
  def rem
    to_remove = `ls #{MUSICS} | fzf`.chomp
    File.delete("#{MUSICS}/#{to_remove}") unless to_remove == ""
  rescue => e
    abort "couldn't remove the file: #{e}"
  end

  desc(*descs[:sync])
  def sync(action)
    abort "sync: missing argument" if action.nil?
    abort "sync #{action}: wrong argument" if !action =~ /get|give/
    Net::SSH.start("homelab") do |ssh|
      ssh.scp.download!("/DATA/Media/Musics", "#{Dir.home}/Music", recursive: true) if action == "get"
      ssh.scp.upload!(MUSICS, "/DATA/Media/", recursive: true) if action == "give"
    end
  rescue => e
    abort "couldn't sync: #{e}"
  end

  def self.exit_on_failure?
    true
  end
end

Ydl.start
```
- I still use `ruby`'s backticks feature for `yt-dlp` and `ffmpeg`
- but it looks much better at usage

It allows me to easily `upload` and `download` the new music between my laptop, server and phone.  
For those using an `iPhone`, you can use `vlc` and `iSH`.
`iSH` is a small `alpine linux` shell allowing to run some scripts and commands, I can run my ruby script like this.
It requires more work but I can download the music to my `iSH` container, then using the file manager of `iOS` move the music to the `vlc` music folder and it is good to go :)