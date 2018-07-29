FROM 1mmortal/docker-pms-plexdrive

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
    g++ && \
  # Get plex_autoscan
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
    g++ && \
  # Clean apt cache
  apt-get clean all && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

COPY root/ /

ADD start.sh /start.sh
RUN chmod +x /start.sh

ENV \
  # Plex_autoscan config file
  PLEX_AUTOSCAN_CONFIG=/config/plex_autoscan/config.json \
  # Plex_autoscan queue db file
  PLEX_AUTOSCAN_QUEUEFILE=/config/plex_autoscan/queue.db \
  # Plex_autoscan log file
  PLEX_AUTOSCAN_LOGFILE=/config/plex_autoscan/plex_autoscan.log \
  # Plex_autoscan disable docker and sudo
  USE_DOCKER=true \
  USE_SUDO=false
