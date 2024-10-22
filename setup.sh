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
rc_local_content="echo \"1-1\" | sudo tee /sys/bus/usb/drivers/usb/unbind
sudo ifconfig eth0 down
exit 0"
rc_local_file="/etc/rc.local"

if ! grep -Fxq "echo \"1-1\" | sudo tee /sys/bus/usb/drivers/usb/unbind" "$rc_local_file"; then
    sudo bash -c "cat <<EOL > $rc_local_file
#!/bin/sh -e
$rc_local_content
EOL"
fi

# Ensure /etc/rc.local is executable
sudo chmod +x /etc/rc.local

# Append dtoverlay=disable-bt to /boot/firmware/config.txt
echo -e "\e[32mDisabling Bluetooth.\e[0m"
config_txt_file="/boot/firmware/config.txt"
dtoverlay_content="dtoverlay=disable-bt"

if ! grep -Fxq "$dtoverlay_content" "$config_txt_file"; then
    echo "$dtoverlay_content" | sudo tee -a "$config_txt_file"
fi

# Append Chromium kiosk mode with the provided URL and unclutter to autostart
echo -e "\e[32mAutostart Chromium.\e[0m"
autostart_file="/etc/xdg/lxsession/LXDE-pi/autostart"
chromium_command="@chromium-browser --kiosk $kiosk_url"
unclutter_command="@unclutter -idle 0.1 -root"

if ! grep -Fxq "$chromium_command" "$autostart_file"; then
    echo "$chromium_command" | sudo tee -a "$autostart_file"
fi

if ! grep -Fxq "$unclutter_command" "$autostart_file"; then
    echo "$unclutter_command" | sudo tee -a "$autostart_file"
fi

# Change Wayland to X11 in raspi-config
echo -e "\e[32mChange to X11.\e[0m"
sudo raspi-config nonint do_wayland W1

# Enable Overlay File System and write-protect boot partition
#echo -e "\e[32mWrite protect system.\e[0m"
#sudo raspi-config nonint enable_overlayfs 0

echo -e "\e[32mScript completed, rebooting in 30 seconds. Remember to run sudo raspi-config nonint enable_overlayfs 0 after reboot.\e[0m"
sleep 30 && sudo reboot
