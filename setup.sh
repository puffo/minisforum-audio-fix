#!/bin/bash
# Minisforum AI Series - ALC245 Audio Fix
# Install/uninstall script
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET_USER="${SUDO_USER:-$USER}"
TARGET_HOME=$(eval echo "~$TARGET_USER")

if [ "$EUID" -ne 0 ]; then
    echo "Please run with: ./install.sh"
    exit 1
fi

uninstall() {
    echo "Removing ALC245 audio fixes..."
    rm -f /etc/modprobe.d/alc245-jack.conf
    rm -f /lib/firmware/alc245-minisforum.fw
    rm -f /etc/xdg/autostart/fix-alc245-headphone.desktop
    rm -f /usr/local/bin/fix-alc245-headphone

    # Clean up old approaches if present
    rm -f /etc/udev/rules.d/99-alc245-headphone.rules
    rm -f /etc/systemd/system/fix-alc245-headphone.service
    rm -f /etc/systemd/user/fix-alc245-headphone.service
    rm -f "$TARGET_HOME/.config/autostart/fix-headphone.desktop"
    rm -f "$TARGET_HOME/fix-headphone.sh"

    echo "Done. Reboot to apply."
}

install() {
    echo "Installing ALC245 audio fixes..."

    # Remove broken custom PipeWire config if present
    PIPEWIRE_CONF="$TARGET_HOME/.config/pipewire/pipewire.conf"
    if [ -f "$PIPEWIRE_CONF" ]; then
        echo "  Backing up custom PipeWire config to pipewire.conf.bak"
        mv "$PIPEWIRE_CONF" "${PIPEWIRE_CONF}.bak"
    fi

    echo "  Installing modprobe config"
    cp "$SCRIPT_DIR/etc/modprobe.d/alc245-jack.conf" /etc/modprobe.d/

    echo "  Installing HDA firmware patch"
    cp "$SCRIPT_DIR/lib/firmware/alc245-minisforum.fw" /lib/firmware/

    echo "  Installing headphone fix script"
    cp "$SCRIPT_DIR/usr/local/bin/fix-alc245-headphone" /usr/local/bin/
    chmod +x /usr/local/bin/fix-alc245-headphone

    echo "  Installing autostart entry"
    cp "$SCRIPT_DIR/etc/xdg/autostart/fix-alc245-headphone.desktop" /etc/xdg/autostart/

    # Clean up old approaches if present
    rm -f /etc/udev/rules.d/99-alc245-headphone.rules
    rm -f /etc/systemd/system/fix-alc245-headphone.service
    rm -f /etc/systemd/user/fix-alc245-headphone.service
    rm -f "$TARGET_HOME/.config/autostart/fix-headphone.desktop"
    rm -f "$TARGET_HOME/fix-headphone.sh"

    echo "Done. Reboot to apply."
}

case "${1:-}" in
    --uninstall)
        uninstall
        ;;
    *)
        install
        ;;
esac
