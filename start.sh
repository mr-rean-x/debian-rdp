#!/bin/bash

# RDP login password: set RDP_PASSWORD env var (Railway Variables e set koro).
# Na set korle default "changeme" hobe — deploy er age obosshoi bodle nio!
RDP_PASSWORD="${RDP_PASSWORD:-changeme}"
echo "root:${RDP_PASSWORD}" | chpasswd

mkdir -p /var/run/dbus /var/run/xrdp /tmp/.X11-unix
chmod 1777 /tmp/.X11-unix
dbus-uuidgen > /var/lib/dbus/machine-id 2>/dev/null || true

# dbus start (fail korleo cholbe, xrdp nije try korbe)
service dbus start 2>/dev/null || /etc/init.d/dbus start 2>/dev/null || true

# Audio: fail korle RDP theme jabe na, sudhu sound thakbe na
pulseaudio --start --system --disallow-exit --disable-shm 2>/dev/null || true

# xrdp start — service script na cholle direct binary diye
service xrdp start 2>/dev/null || /etc/init.d/xrdp start 2>/dev/null || {
  /usr/sbin/xrdp-sesman 2>/dev/null
  /usr/sbin/xrdp 2>/dev/null
}

# Log file na thakle tail fail kore container bondho hoye jeto — tai age touch
touch /var/log/xrdp-sesman.log /var/log/xrdp.log 2>/dev/null || true

echo "xRDP running on port 3389 - login as root"
# -F: file na thakleo / recreate holeo follow kore; tail morleo container bachbe
tail -F /var/log/xrdp-sesman.log /var/log/xrdp.log 2>/dev/null || sleep infinity
