# Plex-Official
https://github.com/plexinc/pms-docker
* Plexdrive-5.0.0 https://github.com/dweidenfeld/plexdrive
* Rclone V1.42    https://github.com/Mumie-hub/docker-services/tree/master/rclone-mount
* Unionfs-fuse    http://manpages.ubuntu.com/manpages/precise/man8/unionfs-fuse.8.html
* Plex_autoscan   https://github.com/l3uddz/plex_autoscan
* Unionfs_Cleaner https://github.com/l3uddz/unionfs_cleaner
* Plex_dupefinder https://github.com/l3uddz/plex_dupefinder


Exemple docker-compose.yml
```
version: '2.1'
services:

  plex:
    container_name: plex
    image: laster13/plexdrive-rclone
    restart: unless-stopped
    network_mode: host
    cap_add:
      - SYS_ADMIN
      - MKNOD
    devices:
      - /dev/fuse
    security_opt:
      - apparmor:unconfined
    environment:
      - TZ=Paris/Europe
      - PLEX_CLAIM=claim-j3ScQyzZwujhyVUP56FJ
      - PLEX_UID=0
      - PLEX_GID=0
    hostname: mail
    volumes:
      - /mnt/docker/Plex/config:/config
      - /dev/shm:/transcode
      - /mnt/docker/Plex/rclone:/mnt/rclone:shared
      - /mnt/docker/Plex/Pre:/mnt/Pre:shared
```           
# Host folder structure example
```
Docker Data
├── pms-docker
│   ├── config
│   │   ├── Library
|   |   |   └── ...
│   │   │
│   │   ├── .plexdrive
│   │   |   └── ...
|   |   | 
|   |   ├── Rclone
|   |   |   └── ...
|   |   |
|   |   ├── Plex_autoscan
|   |   |   └── ...
|   |   |
|   |   ├── Unionfs_cleaner
|   |   |   └── ...
|   |   |
|   |   ├── Plex_dupefinder
|   |       └── ...
|   |   
│   └── transcode
└──
```
# Démo

[![asciicast](https://asciinema.org/a/ByqEAq3tpxn3lIw8mfUvaJ68L.png)](https://asciinema.org/a/ByqEAq3tpxn3lIw8mfUvaJ68L?autoplay=1)
