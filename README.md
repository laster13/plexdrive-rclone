* Plexdrive-5.0.0 https://github.com/dweidenfeld/plexdrive
* Rclone V1.43    https://github.com/Mumie-hub/docker-services/tree/master/rclone-mount
* Unionfs-fuse    http://manpages.ubuntu.com/manpages/precise/man8/unionfs-fuse.8.html
* Unionfs_Cleaner https://github.com/l3uddz/unionfs_cleaner


# Exemple docker-compose.yml
```
version: '3'
services:

  plex:
    container_name: plexdrive
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
      - PLEX_CLAIM=
      - PLEX_UID=0
      - PLEX_GID=0
    hostname: mail
    volumes:
      - /mnt/docker/Plex/config:/config
      - /dev/shm:/transcode
      - /mnt/docker/Plex/rclone:/mnt/Union:shared
      - /mnt/docker/Plex/Pre:/mnt/Pre:shared
``` 

# Variables d'environnement

```
PLEXDRIVE_CONFIG_DIR="/.plexdrive"                  # Dossier de config par default de Plexdrive
PLEXDRIVE_MOUNT_POINT="/home/plexdrive"             # Montage chiffré de plexdrive, par defaut /home/Plex
RemotePath="google:/"                              # Remote chiffré rclone (pointe vers /home/plexdrive
MountPoint="/mnt/rclone"                            # Point de montage non chiffré rclone
MountLocal="/mnt/Pre"                               # Dossier local
MountUnion="/mnt/Union"                             # Dossier Union pour Unionfs-fuse
MountCommands="--allow-other --allow-non-empty"     # Options de montage rclone
UnmountCommands="-u -z"                             # Commandes pour fusermount


    environment:
      - RemotePath="google:/"
      - MountPoint="/mnt/rclone"
      - MountPoint="/mnt/rclone" 
      └── ...
```

# Host folder structure example

```
Docker Data
├── plexdrive
│   ├── config
│   │   |── .config
│   │   |   ├── .plexdrive
│   │   |   |   └── ...
|   |   |   | 
|   |   |   |── rclone
|   |   |       └── ...
|   |   |   
|   |   ├── unionfs_cleaner
|   |   |   └── ...

```

# Démo

[![asciicast](https://asciinema.org/a/ByqEAq3tpxn3lIw8mfUvaJ68L.png)](https://asciinema.org/a/ByqEAq3tpxn3lIw8mfUvaJ68L?autoplay=1)
