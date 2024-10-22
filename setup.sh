#!/bin/bash

# Check if the URL is passed as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 <URL>"
    exit 1
fi

kiosk_url=$1
echo -e "\e[32mURL check, starting script.\e[0m"

# Update and upgrade system
echo -e "\e[32mUpgrading system.\e[0m"
sudo apt update -y
sudo apt upgrade -y
sudo apt dist-upgrade -y

# Install software
echo -e "\e[32mInstalling software.\e[0m"
sudo apt install -y chromium-browser
sudo apt install -y unclutter

# Modify /etc/rc.local
echo -e "\e[32mDisabling ETH port.\e[0m"
sudo bash -c 'cat <<EOL > /etc/rc.local
#!/bin/sh -e
echo "1-1" | sudo tee /sys/bus/usb/drivers/usb/unbind
sudo ifconfig eth0 down
exit 0
EOL'

# Ensure /etc/rc.local is executable
#sudo chmod +x /etc/rc.local

# Append dtoverlay=disable-bt to /boot/firmware/config.txt
echo -e "\e[32mDisabling Bluetooth.\e[0m"
sudo bash -c 'echo "dtoverlay=disable-bt" >> /boot/firmware/config.txt'

# Append Chromium kiosk mode with the provided URL and unclutter to autostart
echo -e "\e[32mAutostart Chromium.\e[0m"
sudo bash -c "cat <<EOL >> /etc/xdg/lxsession/LXDE-pi/autostart
@chromium-browser --kiosk $kiosk_url
@unclutter -idle 0.1 -root
EOL"

# Change Wayland to X11 in raspi-config
echo -e "\e[32mChange to X11.\e[0m"
sudo raspi-config nonint do_wayland W1

# Enable Overlay File System and write-protect boot partition
#echo -e "\e[32mWrite protect system.\e[0m"
#sudo raspi-config nonint enable_overlayfs 0

echo -e "\e[32mScript completed, rebooting in 30 seconds.\e[0m"
sleep 30 && sudo reboot
