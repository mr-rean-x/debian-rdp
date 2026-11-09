FROM debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive

# Retry apt update once (mirror hiccup holeo build fail korbe na)
RUN apt-get update || apt-get update

# Slim install: --no-install-recommends diye image choto + build fast.
# Wine rakha hoy nai — oita image 1GB+ boro kore ar build fail er
# sobcheye boro karon. Wine lagle Dockerfile.wine dekho / README poro.
RUN apt-get install -y --no-install-recommends \
    xrdp \
    xfce4 \
    xorg \
    dbus-x11 \
    sudo \
    curl \
    wget \
    nano \
    net-tools \
    policykit-1 \
    pulseaudio \
    pulseaudio-utils \
    firefox-esr \
    xfce4-terminal \
    thunar && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Allow any user to start X (needed for xrdp sessions)
RUN sed -i 's/^allowed_users=.*/allowed_users=anybody/' /etc/X11/Xwrapper.config || echo "allowed_users=anybody" >> /etc/X11/Xwrapper.config

# XFCE session for the root user
RUN echo "startxfce4" > /root/.xsession && chmod 700 /root/.xsession

# Generate machine-id for dbus
RUN mkdir -p /var/run/dbus && dbus-uuidgen > /var/lib/dbus/machine-id

# xrdp tweaks (same as inspiration repo): low crypt level + plain RDP security layer
RUN sed -i 's/crypt_level=high/crypt_level=low/' /etc/xrdp/xrdp.ini && \
    sed -i 's/security_layer=negotiate/security_layer=rdp/' /etc/xrdp/xrdp.ini && \
    echo "exec startxfce4" > /etc/xrdp/startwm.sh && chmod +x /etc/xrdp/startwm.sh

RUN adduser xrdp ssl-cert

# PulseAudio client config (enables audio over RDP)
COPY pulse-client.conf /etc/pulse/client.conf

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 3389

CMD ["/start.sh"]
