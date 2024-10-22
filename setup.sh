#!/bin/bash

# Check if the URL is passed as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 <URL>"
    exit 1
fi

kiosk_url=$1

# Update and upgrade system
sudo apt update -y
sudo apt upgrade -y
sudo apt dist-upgrade -y

# Install software
sudo apt install -y chromium-browser
sudo apt install -y unclutter

# Modify /etc/rc.local
sudo bash -c 'cat <<EOL > /etc/rc.local
#!/bin/sh -e
echo "1-1" | sudo tee /sys/bus/usb/drivers/usb/unbind
sudo ifconfig eth0 down
exit 0
EOL'

# Ensure /etc/rc.local is executable
#sudo chmod +x /etc/rc.local

# Append dtoverlay=disable-bt to /boot/firmware/config.txt
sudo bash -c 'echo "dtoverlay=disable-bt" >> /boot/firmware/config.txt'

# Append Chromium kiosk mode with the provided URL and unclutter to autostart
sudo bash -c "cat <<EOL >> /etc/xdg/lxsession/LXDE-pi/autostart
@chromium-browser --kiosk $kiosk_url
@unclutter -idle 0.1 -root
EOL"

# Change Wayland to X11 in raspi-config
sudo raspi-config nonint do_wayland W1

# Enable Overlay File System and write-protect boot partition
sudo raspi-config nonint enable_overlayfs 0

echo "Script execution completed."
