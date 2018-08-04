FROM plexinc/pms-docker:public

ENTRYPOINT ["/init"]

ENV \
  PLEXDRIVE_CONFIG_DIR=".plexdrive" \
  CHANGE_PLEXDRIVE_CONFIG_DIR_OWNERSHIP="true" \
  PLEXDRIVE_MOUNT_POINT="/home/Plex" \
  # Plex_autoscan config file
  PLEX_AUTOSCAN_CONFIG=/config/plex_autoscan/config.json \
  # Plex_autoscan queue db file
  PLEX_AUTOSCAN_QUEUEFILE=/config/plex_autoscan/queue.db \
  # Plex_autoscan log file
  PLEX_AUTOSCAN_LOGFILE=/config/plex_autoscan/plex_autoscan.log \
  # Plex_autoscan disable docker and sudo
  USE_DOCKER=false \
  USE_SUDO=false

COPY root/ /

RUN \
  # Install dependencies
  apt-get update && \
  apt-get full-upgrade -y && \
  apt-get install --no-install-recommends -y \
    git \
    lsof \
    python-pip \
    python-dev \
    python3-pip \
    python3.5-dev \
    unionfs-fuse \
    unzip \
    man.db \
    fuse \
    wget \
    g++ && \
  # Get plex_autoscan
  echo "user_allow_other" > /etc/fuse.conf && \
  /plexdrive-install.sh && \
  git clone --depth 1 --single-branch https://github.com/l3uddz/unionfs_cleaner.git /unionfs_cleaner && \
  git clone --depth 1 --single-branch https://github.com/l3uddz/plex_autoscan.git /plex_autoscan && \
  curl https://rclone.org/install.sh | bash && \
  # Install/update pip and requirements
  pip install --no-cache-dir --upgrade pip setuptools wheel && \
  # PIP upgrade bug https://github.com/pypa/pip/issues/5221
  hash -r pip && \
  pip3 install --no-cache-dir --upgrade -r /unionfs_cleaner/requirements.txt && \
  pip install --no-cache-dir --upgrade -r /plex_autoscan/requirements.txt && \
  # Remove dependencies
  apt-get purge -y --auto-remove \
    python-dev \
    python3.5-dev \
    unzip \
    man.db \
    wget \
    g++ && \
  # Clean apt cache
  apt-get clean all && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

ADD start.sh /start.sh
RUN chmod +x /start.sh

HEALTHCHECK --interval=3m --timeout=100s \
CMD test -r $(find ${PLEXDRIVE_MOUNT_POINT} -maxdepth 1 -print -quit) && /healthcheck.sh || exit 1
