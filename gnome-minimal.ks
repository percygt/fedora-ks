url --mirrorlist="https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-$releasever&arch=$basearch"

# Use graphical install
graphical

keyboard --vckeymap=us --xlayouts='us'
lang en_US.UTF-8
timezone Asia/Manila --utc

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
inotify-tools
firefox
make
flatpak
snapper
python3-dnf-plugin-snapper
syncthing
bzip2
https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
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
flatpak install -y flathub md.obsidian.Obsidian

#VSCode
rpm --import https://packages.microsoft.com/keys/microsoft.asc
sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'

#Brave
dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc

%end

# Reboot after installation
reboot --eject