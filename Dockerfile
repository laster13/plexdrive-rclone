FROM ubuntu:16.04

ENTRYPOINT ["/init"]

ENV \
  RemotePath="GDD_Enc:/" \
  MountPoint="/mnt/rclone" \
  MountLocal="/mnt/Pre" \
  MountUnion="/mnt/Union" \
  MountCommands="--allow-other --allow-non-empty" \
  UnmountCommands="-u -z" \
  PLEXDRIVE_CONFIG_DIR=".plexdrive" \
  PLEXDRIVE_MOUNT_POINT="/home/plexdrive" \
  ConfigDir="/config/.config/rclone/" \
  ConfigName="rclone.conf" \
  TERM="xterm" LANG="C.UTF-8" LC_ALL="C.UTF-8"


ARG S6_OVERLAY_VERSION=v1.17.2.0
ARG DEBIAN_FRONTEND="noninteractive"
    
LABEL Description="Plexdrive Rclone Unionfs_cleaner" \
      tags="latest" \
      maintainer="laster13 <https://github.com/laster13>" \
      Unionfs_cleaner="https://github.com/l3uddz/unionfs_cleaner" \
      Plexdrive-5.0.0="https://github.com/dweidenfeld/plexdrive"

RUN \
  # Install dependencies
  apt-get update && \
  apt-get full-upgrade -y && \
  apt-get install --no-install-recommends -y \
    git \
    curl \
    bash \
    lsof \
    python3-pip \
    python3.5-dev \
    unionfs-fuse \
    unzip \
    man.db \
    fuse \
    wget \
    python3-setuptools \
    tzdata \
    xmlstarlet \
    uuid-runtime \
    unrar \
    g++ && \
  curl -J -L -o /tmp/s6-overlay-amd64.tar.gz https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/s6-overlay-amd64.tar.gz && \
  tar xzf /tmp/s6-overlay-amd64.tar.gz -C / && \
  echo "user_allow_other" > /etc/fuse.conf && \
  # Get plex_autoscan, unionfs_cleaner and plex_dupefinder
  git clone --depth 1 --single-branch https://github.com/l3uddz/unionfs_cleaner.git /unionfs_cleaner && \
  curl https://rclone.org/install.sh | bash && \
  # Install/update pip and requirements for plex_autoscan
  pip install --no-cache-dir --upgrade pip setuptools wheel && \
  # PIP upgrade bug https://github.com/pypa/pip/issues/5221
  hash -r pip && \
  # install unionfs_cleaner && plex_dupefinder with python3
  pip3 install --no-cache-dir --upgrade -r /unionfs_cleaner/requirements.txt && \
  # Remove dependencies
  apt-get purge -y --auto-remove \
    python3.5-dev \
    unzip \
    man.db \
    python3-setuptools \
    unrar \
    g++ && \
  # Clean apt cache
  apt-get clean all && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

COPY root/ /

RUN chmod +x /start.sh && \
    chmod +x /plexdrive-install.sh && \
    /plexdrive-install.sh && \

HEALTHCHECK --interval=3m --timeout=100s \
CMD test -r $(find ${PLEXDRIVE_MOUNT_POINT} -maxdepth 1 -print -quit) || exit 1
