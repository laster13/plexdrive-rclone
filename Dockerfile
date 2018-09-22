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
  ConfigDir="/root/.config/rclone/" \
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
  git clone --depth 1 --single-branch https://github.com/l3uddz/unionfs_cleaner.git /unionfs_cleaner && \
  curl https://rclone.org/install.sh | bash && \
  pip3 install --no-cache-dir --upgrade -r /unionfs_cleaner/requirements.txt && \
  apt-get purge -y --auto-remove \
    python3.5-dev \
    unzip \
    man.db \
    python3-setuptools \
    unrar \
    g++ && \
  apt-get clean all && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

COPY root/ /

RUN chmod +x /start.sh && \
    chmod +x /plexdrive-install.sh && \
    /plexdrive-install.sh

HEALTHCHECK --interval=30s --timeout=30s \
CMD test -r $(find ${PLEXDRIVE_MOUNT_POINT} -maxdepth 1 -print -quit) || exit 1
