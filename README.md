# Plex-Official with Plexdrive 5.0 Rclone Unionfs-fuse Plex_autoscan Unionfs_Cleaner

Run example
```
docker run --name plex \
           -d \
           -e TZ=Paris/Europe \
           -e PLEX_CLAIM="claim-ddxa9n2MX6x7xWX2dohz" \
           -e CHANGE_CONFIG_DIR_OWNERSHIP="false" \
           -e RemotePath="GDD_Enc:/" \
           -e MountPoint="/mnt/rclone" \
           -e MountLocal="/mnt/Pre" \
           -e MountUnion="/mnt/Union" \
           -e MountCommands="--allow-other --allow-non-empty" \
           -e UnmountCommands="-u -z" \
           -h toto \
           --net=host \
           -v /mnt/docker/Plex/config:/config \
           -v /dev/shm:/transcode \
           -v /mnt/docker/Plex/Media:/mnt/Pre:shared \
           --cap-add MKNOD \
           --cap-add SYS_ADMIN \
           --device /dev/fuse \
           --security-opt apparmor:unconfined \
           --restart=unless-stopped \
           laster13/plexdrive-rclone
```           
Sources: 

https://github.com/Mumie-hub/docker-services/tree/master/rclone-mount
https://bitbucket.org/sh1ny/docker-pms-plexdrive
https://github.com/l3uddz/plex_autoscan
https://github.com/l3uddz/unionfs_cleaner
