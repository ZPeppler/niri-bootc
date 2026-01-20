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
RUN dnf -y config-manager addrepo --from-repofile=https://pkgs.tailscale.com/stable/fedora/tailscale.repo
# REMOVE COPR REPOS ASAP
RUN dnf -y copr enable errornointernet/quickshell 
RUN dnf -y copr enable dejan/lazygit
RUN dnf -y copr enable avengemedia/dms

# INSTALL PACKAGES
RUN dnf -y update
RUN dnf -y install @development-tools
RUN grep -vE '^#' /usr/local/share/niri-bootc/packages-added | xargs dnf -y install --allowerasing

# REMOVE PACKAGES
RUN grep -vE '^#' /usr/local/share/niri-bootc/packages-removed | xargs dnf -y remove
RUN dnf -y autoremove
RUN dnf clean all


# CONFIGURATION
COPY --chmod=0644 ./system/etc_skel_niri-bootc /etc/skel/.bashrc.d/niri-bootc
COPY --chmod=0644 ./system/etc_sddm.conf.d_theme.conf /etc/sddm.conf.d/theme.conf

# USERS

# SYSTEMD
RUN mkdir -p /etc/systemd/system/multi-user.target.wants/ && \
  ln -s /usr/lib/systemd/system/xdg-desktop-portal.service /etc/systemd/system/multi-user.target.wants/xdg-desktop-portal.service && \
  ln -s /usr/lib/systemd/system/xdg-desktop-portal-wlr.service /etc/systemd/system/multi-user.target.wants/xdg-desktop-portal-wlr.service && \
  ln -s /usr/lib/systemd/system/xdg-desktop-portal-gtk.service /etc/systemd/system/multi-user.target.wants/xdg-desktop-portal-gtk.service
RUN systemctl enable cockpit.socket

COPY --chmod=0644 ./systemd/usr_lib_systemd_system_bootc-fetch.service /usr/lib/systemd/system/bootc-fetch.service
COPY --chmod=0644 ./systemd/usr_lib_systemd_system_bootc-fetch.timer /usr/lib/systemd/system/bootc-fetch.timer

RUN systemctl enable bootloader-update.service
RUN systemctl mask bootc-fetch-apply-updates.timer

# NEOVIDE
COPY ./applications/usr_share_applications_neovide.desktop \
    /usr/share/applications/neovide.desktop
ADD --chmod=0644 https://raw.githubusercontent.com/neovide/neovide/main/assets/neovide.svg \
    /usr/share/icons/hicolor/scalable/apps/neovide.svg
ADD --chmod=0644 https://raw.githubusercontent.com/neovide/neovide/main/assets/neovide.svg \
    /usr/share/icons/Adwaita/scalable/apps/neovide.svg

# CLEAN & CHECK
RUN find /var/log -type f ! -empty -delete
RUN bootc container lint
