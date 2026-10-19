#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

# Run as your desktop user, from a terminal in your graphical session.
: "${DISPLAY:?DISPLAY is not set; run this from your desktop session}"

AUTH_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/px4"
XAUTH="$AUTH_DIR/docker.xauth"

mkdir -p "$AUTH_DIR"
chmod 700 "$AUTH_DIR"

if [ -d "$XAUTH" ]; then
    echo "Expected an authentication file, but found a directory: $XAUTH" >&2
    exit 1
fi

# Get credentials for the current display.
xauth_list="$(xauth nlist "$DISPLAY" | sed 's/^..../ffff/')"

if [ -z "$xauth_list" ]; then
    echo "No X11 authentication credentials found for DISPLAY=$DISPLAY" >&2
    exit 1
fi

touch "$XAUTH"
chmod 600 "$XAUTH"
printf '%s\n' "$xauth_list" | xauth -f "$XAUTH" nmerge -

# Recreate the container with the current display and mount settings.
if docker container inspect px4 >/dev/null 2>&1; then
    docker stop px4
    docker rm px4
fi

docker run -it --init \
    --gpus all \
    --network host \
    --name px4 \
    --workdir /home/ubuntu/workspace \
    --env "DISPLAY=$DISPLAY" \
    --env QT_X11_NO_MITSHM=1 \
    --env XAUTHORITY=/tmp/docker.xauth \
    --env NVIDIA_DRIVER_CAPABILITIES=graphics,utility,compute,display \
    --mount type=bind,source=/tmp/.X11-unix,target=/tmp/.X11-unix,readonly \
    --mount "type=bind,source=$XAUTH,target=/tmp/docker.xauth,readonly" \
    --mount "type=bind,source=$REPO_ROOT,target=/home/ubuntu/workspace" \
    --user ubuntu \
    px4-jazzy \
    /bin/bash
