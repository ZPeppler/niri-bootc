FROM quay.io/fedora/fedora-bootc:43
LABEL ostree.bootable=true
LABEL org.opencontainers.image.source=https://github.com/zpeppler/niri-bootc

# SETUP FILESYSTEM
RUN rmdir /opt && ln -s -T /var/opt /opt
RUN mkdir /var/roothome

# PREPARE PACKAGES
COPY --chmod=0644 ./system/usr_local_share_niri-bootc_packages-removed /usr/local/share/niri-bootc/packages-removed
COPY --chmod=0644 ./system/usr_local_share_niri-bootc_packages-added /usr/local/share/niri-bootc/packages-added
RUN jq -r .packages[] /usr/share/rpm-ostree/treefile.json > /usr/local/share/niri-bootc/packages-fedora-bootc 

# INSTALL REPOS
RUN dnf -y install dnf5-plugins
# REMOVE COPR REPOS ASAP
RUN dnf -y copr enable errornointernet/quickshell 
RUN dnf -y copr enable dejan/lazygit

# INSTALL PACKAGES
RUN grep -vE '^#' /usr/local/share/niri-bootc/packages-added | xargs dnf -y install --allowerasing

# REMOVE PACKAGES
# RUN grep -vE '^#' /usr/local/share/niri-bootc/packages-removed | xargs dnf -y remove
RUN dnf -y autoremove
RUN dnf clean all


# CONFIGURATION
COPY --chmod=0644 ./system/etc_skel_niri-bootc /etc/skel/.bashrc.d/niri-bootc

# USERS

# SYSTEMD
RUN mkdir -p /etc/systemd/system/multi-user.target.wants/ && \
  ln -s /usr/lib/systemd/system/xdg-desktop-portal.service /etc/systemd/system/multi-user.target.wants/xdg-desktop-portal.service && \
  ln -s /usr/lib/systemd/system/xdg-desktop-portal-wlr.service /etc/systemd/system/multi-user.target.wants/xdg-desktop-portal-wlr.service && \
  ln -s /usr/lib/systemd/system/xdg-desktop-portal-gtk.service /etc/systemd/system/multi-user.target.wants/xdg-desktop-portal-gtk.service


# CLEAN & CHECK
RUN find /var/log -type f ! -empty -delete
RUN bootc container lint
