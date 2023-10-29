url --mirrorlist="https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-$releasever&arch=$basearch"


# Use graphical install
graphical

# Install system packages
%packages
@base-x
@fonts
@multimedia                            # Common audio/video frameworks
fedora-workstation-repositories        # Default Fedora repositories
rpmfusion-free-release
rpmfusion-nonfree-release
gnome-console
gnome-disk-utility
gnome-shell
gnome-system-monitor
gnome-tweaks
gnome-user-share
nautilus
file-roller
gnome-session-xsession
NetworkManager-wifi
xdg-user-dirs
xdg-user-dirs-gtk
xdg-utils
xdg-desktop-portal-gnome
gvfs*
git
bash-completion
wget
unzip
micro
inotify-tools
firefox
make
flatpak
snapper
python3-dnf-plugin-snapper
plymouth-system-theme
%end

%post
# Set the plymouth theme
plymouth-set-default-theme bgrt -R

# Change Systemd boot target
systemctl set-default graphical.target

systemctl enable gdm bluetooth NetworkManager

grub2-editenv - unset menu_auto_hide

# Configure Flatpak
systemctl disable flatpak-add-fedora-repos
flatpak remote-add flathub https://dl.flathub.org/repo/flathub.flatpakrepo

ROOT_UUID="$(grub2-probe --target=fs_uuid /)"
OPTIONS="$(grep '/home' /etc/fstab | awk '{print $4}' | cut -d, -f2-)"

SUBVOLUMES=(
    "opt"
    "var/cache"
    "var/crash"
    "var/log"
    "var/spool"
    "var/tmp"
    "var/www"
    "var/lib/AccountsService"
    "var/lib/gdm"
    "home/$USER/.mozilla"
    "home/$USER/.config/BraveSoftware"
)

for dir in "${SUBVOLUMES[@]}" ; do
    if [[ -d "/${dir}" ]] ; then
        mv -v "/${dir}" "/${dir}-old"
        btrfs subvolume create "/${dir}"
        cp -ar "/${dir}-old/." "/${dir}/"
    else
        btrfs subvolume create "/${dir}"
    fi
    restorecon -RF "/${dir}"
    printf "%-41s %-24s %-5s %-s %-s\n" \
        "UUID=${ROOT_UUID}" \
        "/${dir}" \
        "btrfs" \
        "subvol=${dir},${OPTIONS}" \
        "0 0" | \
        tee -a /etc/fstab
done

chmod 1777 /var/tmp
chmod 1770 /var/lib/gdm
chown -R $USER: /home/$USER/.mozilla
chown -R $USER: /home/$USER/.config/BraveSoftware

systemctl daemon-reload
mount -va

for dir in "${SUBVOLUMES[@]}" ; do
    if [[ -d "/${dir}-old" ]] ; then
        rm -rf "/${dir}-old"
    fi
done

%end

# Reboot after installation
reboot --eject