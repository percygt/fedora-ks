url --mirrorlist="https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-$releasever&arch=$basearch"

# Use graphical install
graphical

# Install system packages
%packages
@base-x
@fonts
@multimedia                            # Common audio/video frameworks
fedora-workstation-repositories        # Default Fedora repositories
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

# Install Flatpak apps
flatpak install -y flathub com.mattjakeman.ExtensionManager
%end

# Reboot after installation
reboot --eject