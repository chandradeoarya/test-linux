#!/usr/bin/env bash
set -e

# Default VNC display port and noVNC listen port
VNC_DISPLAY=":0"
VNC_PORT=5900
# Use PORT env if provided (e.g., Coolify), else default to 6080
NO_VNC_PORT="${PORT:-6080}"

# Function to clean up background processes on exit
cleanup() {
    echo "Shutting down..."
    # Kill child processes; use pkill or kill by PID if you track them
    pkill -f "Xvfb ${VNC_DISPLAY}" || true
    pkill -f "fluxbox" || true
    pkill -f "x11vnc" || true
    pkill -f "websockify" || true
}
trap cleanup EXIT

# Start Xvfb
echo "Starting Xvfb on display ${VNC_DISPLAY}..."
Xvfb ${VNC_DISPLAY} -screen 0 1024x768x24 &

# Give Xvfb a moment
sleep 1

# Start window manager (fluxbox) on the X display
echo "Starting Fluxbox..."
DISPLAY=${VNC_DISPLAY} fluxbox &

# Give fluxbox a moment
sleep 1

# Start x11vnc to serve the X display
# -forever: keep listening after client disconnect
# -nopw: no password (for production consider adding a password or token!)
# -shared: allow multiple clients
# -rfbport: port 5900
echo "Starting x11vnc on port ${VNC_PORT}..."
x11vnc -display ${VNC_DISPLAY} -nopw -forever -shared -rfbport ${VNC_PORT} &

# Give x11vnc a moment
sleep 1

# Start noVNC's websockify proxy
# We'll use the bundled launch.sh which invokes websockify under the hood
echo "Starting noVNC, listening on port ${NO_VNC_PORT}, proxying to VNC ${VNC_PORT}..."
# The --listen option: noVNC 1.x uses --listen. If using newer noVNC where launch.sh requires --listen, this works.
# If your version uses --vnc-host/--vnc-port, launch.sh auto-detects default of localhost:5900.
# Explicitly pass the port:
exec /opt/noVNC/utils/launch.sh --vnc localhost:${VNC_PORT} --listen ${NO_VNC_PORT}
