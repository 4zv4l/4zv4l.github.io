---
layout: post
tags: [linux]
sticky: true
hidden: true # because of sticky, prevent being twice in the list
excerpt_separator: "\n\n"
---

Simply presenting my `homelab` and the services running on it.

My homelab setup is really simple:
- Zimaboard 832
- 512gb SSD
- Debian 11

For the services I run them inside containers for simplicity and security.
To manage my containers I use [portainer community edition](https://www.portainer.io/) which itself runs in a container.

The interface looks like this:

![portainer dashboard](/assets/2023-04-26-My-homelab/portainer_dashboard.png)
> portainer dashboard

![portainer containers](/assets/2023-04-26-My-homelab/portainer_containers.png)
> portainer containers

On the screenshot we can see the services I run:
- [Gitea](https://gitea.io/en-us/)  
Personal `git` server.
- [Transmission](https://transmissionbt.com/)  
Torrent client.
- [Prowlarr](https://wiki.servarr.com/en/prowlarr)  
Used to fetch torrents on multiple repositories.
- [Radarr](https://radarr.video/)  
Fetch movies using Prowlarr.
- [Sonarr](https://sonarr.tv/)  
Fetch series using Prowlarr.
- [Bazarr](https://www.bazarr.media/)  
Fetch subtitiles for my movies and series.
- [JellyFin](https://jellyfin.org/)  
Media center for movies, series, musics and books.
- [Wg-easy](https://github.com/WeeJeWel/wg-easy/blob/master/README.md)  
Wireguard VPN server made easy.
- [Jekyll](https://jekyllrb.com/)  
My blog.
- [Adguard](https://adguard.com/en/welcome.html)  
Similar to Pi-Hole, I used it as local DNS server.
- [Dashdot](https://getdashdot.com/)  
Widget with system info (ram usage, cpu usage ...).
- [Homarr](https://homarr.dev/)  
Home page.

My Homarr home page looks like this:

![Homarr Home Page](/assets/2023-04-26-My-homelab/homarr_home_page.png)
> Homarr Home Page

Since I don't know much `docker-compose` I used a tool called [autocompose](https://github.com/Red5d/docker-autocompose).  
It is a tool made in Python to generate a `docker-compose` file from the running containers.  
You can simply run it with:
`autocompose.py $(docker ps -aq)`

