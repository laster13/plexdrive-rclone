#!/usr/bin/with-contenv bash

# mkdir -p $ConfigDir

# ConfigPath="$ConfigDir/$ConfigName"

echo "=================================================="
echo "Mounting $RemotePath to $MountPoint at: $(date +%Y.%m.%d-%T)"

#export EnvVariable

function term_handler {
  echo "sending SIGTERM to child pid"
  kill -SIGTERM ${!}
  fuse_unmount
  echo "exiting container now"
  exit $?
}

function cache_handler {
  echo "sending SIGHUP to child pid"
  kill -SIGHUP ${!}
}

function fuse_unmount {
  echo "Unmounting: fusermount $UnmountCommands $MountPoint at: $(date +%Y.%m.%d-%T)"
  fusermount $UnmountCommands $MountPoint
}

#traps, SIGHUP is for cache clearing
trap term_handler SIGINT SIGTERM
trap cache_handler SIGHUP

#mount rclone remote and wait
rclone --config=/config/.config/rclone/rclone.conf mount $RemotePath $MountPoint $MountCommands & wait ${!}
echo "rclone crashed at: $(date +%Y.%m.%d-%T)"
fuse_unmount

exit $?
