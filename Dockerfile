FROM plexinc/pms-docker:public

ENTRYPOINT ["/init"]

ENV \
  RemotePath="GDD_Enc:/" \
  MountPoint="/mnt/rclone" \
  MountLocal="/mnt/Pre" \
  MountUnion="/mnt/Union" \
  MountCommands="--allow-other --allow-non-empty" \
  UnmountCommands="-u -z" \
  PLEXDRIVE_CONFIG_DIR=".plexdrive" \
  CHANGE_PLEXDRIVE_CONFIG_DIR_OWNERSHIP="true" \
  PLEXDRIVE_MOUNT_POINT="/home/Plex" \
  PLEX_AUTOSCAN_CONFIG=/config/plex_autoscan/config.json \
  PLEX_AUTOSCAN_QUEUEFILE=/config/plex_autoscan/queue.db \
  PLEX_AUTOSCAN_LOGFILE=/config/plex_autoscan/plex_autoscan.log \
  USE_DOCKER=false \
  USE_SUDO=false

LABEL Description="Plex Plexdrive Rclone Plex_autoscan Unionfs_cleaner Plex_dupefinder" \
      tags="latest" \
      maintainer="laster13 <https://github.com/laster13>" \
      Plex_autoscan="https://github.com/l3uddz/plex_autoscan" \
      Unionfs_cleaner="https://github.com/l3uddz/unionfs_cleaner" \
      Plex_dupefinder="https://github.com/l3uddz/plex_dupefinder" \
      Plexdrive-5.0.0="https://github.com/dweidenfeld/plexdrive"

RUN \
  # Install dependencies
  apt-get update && \
  apt-get full-upgrade -y && \
  apt-get install --no-install-recommends -y \
    git \
    lsof \
    cron \
    python3-pip \
    python3.5-dev \
    unionfs-fuse \
    unzip \
    man.db \
    fuse \
    wget \
    python3-setuptools \
    g++ && \
  echo "user_allow_other" > /etc/fuse.conf && \
  # Get plex_autoscan, unionfs_cleaner and plex_dupefinder
  git clone --depth 1 --single-branch https://github.com/l3uddz/unionfs_cleaner.git /unionfs_cleaner && \
  git clone --depth 1 --single-branch https://github.com/l3uddz/plex_autoscan.git /plex_autoscan && \
  git clone --depth 1 --single-branch https://github.com/l3uddz/plex_dupefinder.git && \
  curl https://rclone.org/install.sh | bash && \
  # Install/update pip and requirements
  pip3 install --no-cache-dir --upgrade pip setuptools wheel && \
  # PIP upgrade bug https://github.com/pypa/pip/issues/5221
  hash -r pip && \
  pip3 install --no-cache-dir --upgrade -r /unionfs_cleaner/requirements.txt && \
  pip3 install --no-cache-dir --upgrade -r /plex_dupefinder/requirements.txt && \
  pip3 install --no-cache-dir --upgrade -r /plex_autoscan/requirements.txt && \
  # update plex_autoscan with python3.5
  cd /plex_autoscan && \
  sed -i -e "s/import Queue/import queue/g" threads.py && \
  sed -i -e "s/self._waiter_queue = Queue.PriorityQueue()/self._waiter_queue = queue.PriorityQueue()/g" threads.py && \
  sed -i -e "s/from urllib import urlencode/from urllib.parse import urlencode/g" gdrive.py && \
  # Remove dependencies
  apt-get purge -y --auto-remove \
    python3.5-dev \
    unzip \
    man.db \
    python3-setuptools \
    g++ && \
  # Clean apt cache
  apt-get clean all && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

COPY root/ /

RUN chmod +x /start.sh && \
    /plexdrive-install.sh && \
    touch /var/log/cron.log

# Run the command on container startup
CMD cron && tail -f /var/log/cron.log
    
HEALTHCHECK --interval=3m --timeout=100s \
CMD test -r $(find ${PLEXDRIVE_MOUNT_POINT} -maxdepth 1 -print -quit) && /healthcheck.sh || exit 1