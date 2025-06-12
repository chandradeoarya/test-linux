# Use a slim Debian base
FROM debian:bookworm-slim

# Prevent interactive prompts during installs
ENV DEBIAN_FRONTEND=noninteractive

# Install minimal GUI components and utilities:
# - Xvfb: virtual framebuffer X server
# - fluxbox: lightweight window manager
# - xterm: simple terminal emulator
# - x11vnc: VNC server to serve the Xvfb display
# - wget & ca-certificates: for downloading inside container
# - git & python3: for cloning and running noVNC/websockify
# - fontconfig + fonts-dejavu-core: minimal fonts so UI elements can render text
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       xvfb \
       fluxbox \
       xterm \
       x11vnc \
       wget \
       ca-certificates \
       git \
       python3 \
       fontconfig \
       fonts-dejavu-core \
    && rm -rf /var/lib/apt/lists/*

# Install noVNC and websockify into /opt/noVNC
RUN git clone --depth 1 https://github.com/novnc/noVNC.git /opt/noVNC \
    && git clone --depth 1 https://github.com/novnc/websockify.git /opt/noVNC/utils/websockify

# Copy entrypoint script
COPY entrypoint.sh /opt/entrypoint.sh
RUN chmod +x /opt/entrypoint.sh

# Expose the default noVNC port
EXPOSE 6080

# Default command: run our entrypoint
CMD ["/opt/entrypoint.sh"]
