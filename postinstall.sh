#!/usr/bin/env bash
echo "___________________________________________________________________________________"
echo "                                                                                   "
echo "                           REMOVE UNNECESSARY APPS                                "
echo "___________________________________________________________________________________"
# Remove apps that 99% of regular users will never use (offline mail app; linux distro loader; a backup tool that requires the tool to view/recover the files; a tool to create bootable usb drives) 
flatpak uninstall -y --delete-data org.mozilla.Thunderbird com.ranfdev.DistroShelf org.gnome.DejaDup io.gitlab.adhami3310.Impression
flatpak uninstall -y --unused

echo "___________________________________________________________________________________"
echo "                                                                                   "
echo "   Add a language for flatpak apps (required for Office apps, spellcheckers etc)   "
echo "___________________________________________________________________________________"
# Get language & region info
echo "___________________________________________________________________"
read -p "Besides English, would you like spellchecker support for another language? (y/n)" answer
case ${answer:0:1} in
    y|Y )
    echo "Please type the 2-letter countrycode for the language, for example "de" for German language (no caps):"
    echo "___________________________________________________________________"
    read -p 'countrycode for example "de" and hit ENTER: ' LANG
    flatpak config --system --set languages "en;$LANG"
    flatpak update -y ;;
    n|N ) ;;
    * ) ;;
esac

echo "___________________________________________________________________________________"
echo "                                                                                   "
echo "               APPLICATIONS - Install required and recommended apps                "
echo "___________________________________________________________________________________"
# Install applications/tools via the proper method (Flatpak)
# Install Gearlever, a tool to install/integrate AppImage versions of Apps (for apps that are not available via Bazaar/are not on Flathub.org)
flatpak install -y flathub it.mijorus.gearlever
# Install CameraCtrls - to adjust webcam video quality settings, required on Linux for laptop webcams that are not fully supported. 
flatpak install -y flathub hu.irl.cameractrls
# Tool to sync a folder to external drive, incremental changes only (to backup your personal files to an external drive) 
flatpak install -y flathub org.freefilesync.FreeFileSync
# Music player Amberol
flatpak install -y flathub io.bassi.Amberol
# Music editor tool
flatpak install -y flathub org.audacityteam.Audacity
# Image editor tool
flatpak install -y flathub com.github.PintaProject.Pinta
# GIMP advanced image editor
flatpak install -y flathub org.gimp.GIMP  
# Video converter
flatpak install -y flathub fr.handbrake.ghb
# Video trimmer, simple & lossless
flatpak install -y flathub org.gnome.gitlab.YaLTeR.VideoTrimmer
# Video trimmer, lossless, with more options, converter, merger
flatpak install -y flathub no.mifi.losslesscut
# Collabora Office (for OpenDocument files, supports MS Office files as well)
flatpak install -y flathub com.collaboraoffice.Office
# OnlyOffice (Simpler suite, only for Microsoft Office files)
flatpak install -y flathub org.onlyoffice.desktopeditors
# OnlyOffice: create its config file, add the setting to always open docs in their own window instead of tabs
mkdir -p $HOME/.var/app/org.onlyoffice.desktopeditors/config/onlyoffice
tee $HOME/.var/app/org.onlyoffice.desktopeditors/config/onlyoffice/DesktopEditors.conf &>/dev/null << EOF
editorWindowMode=true
EOF

echo "___________________________________________________________________________________"
echo "                                                                                   "
echo "           GNOME EXTENSIONS - Required for usable and intuitive system             "
echo "___________________________________________________________________________________"
#Install extensions, required for the configuration that will be applied in the next step (00-gnome-intuitive)
wget -P $HOME/Downloads/ https://raw.githubusercontent.com/ToasterUwU/install-gnome-extensions/master/install-gnome-extensions.sh
# Dash-to-Panel (dash-to-panel@jderose9.github.com)
bash $HOME/Downloads/install-gnome-extensions.sh --enable 1160
# ArcMenu (arcmenu@arcmenu.com)
bash $HOME/Downloads/install-gnome-extensions.sh --enable 3628
# Tiling Shell (tilingshell@ferrarodomenico.com)
bash $HOME/Downloads/install-gnome-extensions.sh --enable 7065
# Allow Locked Remote Desktop (allowlockedremotedesktop@kamens.us)
bash $HOME/Downloads/install-gnome-extensions.sh --enable 3193
# Desktop Icons (gtk4-ding@smedius.gitlab.com)
bash $HOME/Downloads/install-gnome-extensions.sh --enable 4338
# Blur My Shell ()
bash $HOME/Downloads/install-gnome-extensions.sh --enable 5263
# Removable Drive menu (drive-menu@gnome-shell-extensions.gcampax.github.com)
bash $HOME/Downloads/install-gnome-extensions.sh --enable 7
# Custom Hot Corners (custom-hot-corners-extended@G-dH.github.com)
bash $HOME/Downloads/install-gnome-extensions.sh --enable 4167
# Bing Wallpaper (BingWallpaper@ineffable-gmail.com)
mkdir -p $HOME/Pictures/Wallpapers
bash $HOME/Downloads/install-gnome-extensions.sh --enable 1262
#remove the script used to install extensions. 
rm $HOME/Downloads/install-gnome-extensions.sh 

echo "___________________________________________________________________________________"
echo "                                                                                   " 
echo "            GNOME - Intuitive configuration for Gnome, Extensions, Apps            "
echo "___________________________________________________________________________________"
# Apply Gnome configurations, using the method recommended by Gnome. Documentation: https://help.gnome.org/admin/system-admin-guide/stable/dconf-custom-defaults.html.en
# This is applied system-wide, however, the enxtensions were installed for this user only. New users will need to manually install those extentsions for this configuration to work as intended. 
# First create a dconf profile
sudo mkdir -p /etc/dconf/profile
sudo tee /etc/dconf/profile/user &>/dev/null << EOF
user-db:user
system-db:local
EOF
# Download the Gnome Intuitive configuration and apply
sudo wget -P /etc/dconf/db/local.d https://raw.githubusercontent.com/zilexa/Bluefin-Gnome-ReadyToGo-Desktop/main/00-gnome-intuitive
sudo dconf update

echo "___________________________________________________________________________________"
echo "                                                                                   "
echo "     FIREFOX - essential extensions + clean toolbar layout + related settings      "
echo "___________________________________________________________________________________"
# Create default policies (install minimal set of extensions and theme, configure the toolbar layout and allow Firefox Sync to include your toolbar layout when syncing, disable default Mozilla bookmarks)
# first delete existing profiles
rm -f -r $HOME/.var/app/org.mozilla.firefox/config/mozilla/firefox/*.default*
rm -f $HOME/.var/app/org.mozilla.firefox/config/mozilla/firefox/profiles.ini
rm -f -r $HOME/.var/app/org.mozilla.firefox/cache/mozilla/firefox/*.default*

# Create default firefox policies
sudo mkdir -p /var/lib/flatpak/extension/org.mozilla.firefox.systemconfig/x86_64/stable/policies
sudo tee /var/lib/flatpak/extension/org.mozilla.firefox.systemconfig/x86_64/stable/policies/policies.json &>/dev/null << EOF
{
  "policies": {
    "DisableProfileImport": true,
    "NoDefaultBookmarks": true,
    "DisplayBookmarksToolbar": "always",
    "Extensions": {
      "Install": [
        "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi",
        "https://gitflic.ru/project/magnolia1234/bpc_uploads/blob/raw?file=bypass_paywalls_clean-latest.xpi",
        "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi",
        "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi",
        "https://addons.mozilla.org/firefox/downloads/latest/nord-polar-night-theme/latest.xpi"
      ]
    },
    "Preferences": {
      "extensions.unifiedExtensions.button.always_visible": false,
      "services.sync.prefs.sync.browser.uiCustomization.state": true,
      "browser.uiCustomization.state": {
        "Value": "{\"placements\":{\"widget-overflow-fixed-list\":[],\"unified-extensions-area\":[\"sponsorblocker_ajay_app-browser-action\",\"magnolia_12_34-browser-action\",\"_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action\"],\"nav-bar\":[\"sidebar-button\",\"back-button\",\"forward-button\",\"stop-reload-button\",\"customizableui-special-spring1\",\"vertical-spacer\",\"downloads-button\",\"ublock0_raymondhill_net-browser-action\",\"urlbar-container\",\"customizableui-special-spring2\",\"unified-extensions-button\"],\"toolbar-menubar\":[\"menubar-items\"],\"TabsToolbar\":[\"tabbrowser-tabs\",\"new-tab-button\",\"alltabs-button\"],\"vertical-tabs\":[],\"PersonalToolbar\":[\"fxa-toolbar-menu-button\",\"history-panelmenu\",\"firefox-view-button\",\"import-button\",\"personal-bookmarks\"]},\"seen\":[\"developer-button\",\"screenshot-button\",\"magnolia_12_34-browser-action\",\"sponsorblocker_ajay_app-browser-action\",\"ublock0_raymondhill_net-browser-action\",\"_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action\"],\"dirtyAreaCache\":[\"nav-bar\",\"vertical-tabs\",\"PersonalToolbar\",\"toolbar-menubar\",\"TabsToolbar\",\"unified-extensions-area\",\"widget-overflow-fixed-list\"],\"currentVersion\":23,\"newElementCount\":6}",
        "Status": "default"
      }
    }
  }
}
EOF

echo "___________________________________________________________________________________"
echo "                                                                                   "
echo "       Install all MS OFFICE465 FONTS - required for document compatibility        "
echo "___________________________________________________________________________________"
# Get a script that uses MEGA api to donwload a file
wget -P $HOME/Downloads/ https://raw.githubusercontent.com/tonikelope/megadown/refs/heads/master/megadown
# Get the fonts via MEGA
/bin/bash $HOME/Downloads/megadown 'https://mega.nz/#!u4p02JCC!HnJOVyK8TYDqEyVXLkwghDLKlKfIq0kOlX6SPxH53u0'
# remove the helper script
rm $HOME/Downloads/megadown
rm -r $HOME/Downloads/.megadown
# Extract to systems font folder
mkdir -p $HOME/.local/share/fonts
tar -xvf $HOME/Downloads/fonts-office365.tar.xz -C $HOME/.local/share/fonts
# Refresh the font cache (= register the fonts)
fc-cache -f -v
# Remove the downloaded font file
rm $HOME/Downloads/fonts-office365.tar.xz

echo "___________________________________________________________________________________"
echo "                                                                                   "
echo "             Simplify folder structure and populate Templates folder               "
echo "___________________________________________________________________________________"
# Create empty files in Templates to be able to create these new files via File Manager
# Plain text (empty is fine)
touch ~/Templates/"New Text file.txt"
touch ~/Templates/"New Markdown file.md"
touch ~/Templates/"New CSV file.csv"
# ODF formats (need a valid mimetype ZIP entry)
python3 - << 'EOF'
import zipfile, os

def make_odf(path, mimetype):
    with zipfile.ZipFile(path, 'w', zipfile.ZIP_STORED) as z:
        info = zipfile.ZipInfo('mimetype')
        info.compress_type = zipfile.ZIP_STORED
        z.writestr(info, mimetype)

t = os.path.expanduser('~/Templates')
make_odf(f'{t}/New Document.odt',    'application/vnd.oasis.opendocument.text')
make_odf(f'{t}/New Spreadsheet.ods', 'application/vnd.oasis.opendocument.spreadsheet')
make_odf(f'{t}/New Presentation.odp','application/vnd.oasis.opendocument.presentation')
EOF
echo "Templates created."
      
# Disable the "Public" folder in Home, it has no function: 
xdg-user-dirs-update --set PUBLICSHARE "$HOME"
# Rename the Videos folder to Media, more generic, could be used ask working folder for video editing or form torrent downloads
mkdir $HOME/Media
xdg-user-dirs-update --set VIDEOS "$HOME/Media"
xdg-user-dirs-update
# Now remove the disabled folders
rmdir ~/Videos ~/Public
# And update the bookmarks in Nautilus File Manager
cat <<EOF > "$HOME/.config/gtk-3.0/bookmarks"
file://$HOME/Downloads Downloads
file://$HOME/Documents Documents
file://$HOME/Pictures Pictures
file://$HOME/Music Music
file://$HOME/Media Media
EOF

echo "___________________________________________________________________________________"
echo "                                                                                   "
echo "                   Enable Hibernation and Suspend-then-Hibernate                   "
echo "___________________________________________________________________________________"
# For hibernation to work, the RAM memory has to be written to the Storage device, specifically for the BTRFS filesystem: to a subvolume. This is better than a separate partition as it will keep your SSD healthy. 
SWAPSIZE=$(free | awk '/Mem/ {x=$2/1024/1024; printf "%.0fG", (x<2 ? 2*x : x<8 ? 1.5*x : x) }')
sudo btrfs subvolume create /var/swap
sudo chattr +C /var/swap
sudo restorecon /var/swap
sudo mkswap --file -L SWAPFILE --size $SWAPSIZE /var/swap/swapfile
sudo bash -c 'echo /var/swap/swapfile none swap defaults 0 0 >>/etc/fstab'
sudo swapon -av

# if Hibernation does not work, SELinux needs to be configured. Not part of this script. 

# Now configure the system: Power key -> hibernate. When the system is idle for 30min or when closing the laptop -> suspend for 75min then hibernate (zero power consumption, to prevent battery drain). 
sudo mkdir -p /etc/systemd/logind.conf.d
sudo tee /etc/systemd/logind.conf.d/lid.conf > /dev/null <<EOF
[Login]
HandlePowerKey=hibernate
HandleLidSwitch=suspend-then-hibernate
LidSwitchIgnoreInhibited=yes
HoldoffTimeoutSec=20s
IdleAction=suspend-then-hibernate
#IdleActionSec=30min commented out because logind cannot distinguish between battery power or AC so will always suspend.. this needs to be configured in Gnome settings.
EOF

echo "Creating /etc/systemd/sleep.conf.d/sleep.conf ..."
sudo mkdir -p /etc/systemd/sleep.conf.d
sudo tee /etc/systemd/sleep.conf.d/sleep.conf > /dev/null <<EOF
[Sleep]
HibernateDelaySec=75min
EOF

echo ""
echo "Completed successfully, please close this window and reboot!"


echo "___________________________________________________________________________________"
echo "                                                                                   "
echo "                                Optional, after the reboot                         "
echo "___________________________________________________________________________________"
# Start Tailscale systray
# sudo tailscale set --operator=$USER
# tailscale configure systray --enable-startup=systemd
# systemctl --user enable --now tailscale-systray
# now use the systray to login to your Tailscale otherwise the first command needs to be executed again.
