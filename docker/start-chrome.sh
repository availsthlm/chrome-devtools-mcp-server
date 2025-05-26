#!/bin/bash

# Wait for Xvfb to be ready
sleep 2

# Start Chrome with remote debugging enabled
exec /usr/bin/google-chrome \
    --remote-debugging-port=9222 \
    --remote-debugging-address=0.0.0.0 \
    --no-first-run \
    --no-default-browser-check \
    --no-sandbox \
    --disable-dev-shm-usage \
    --disable-gpu \
    --disable-extensions \
    --disable-plugins \
    --disable-images \
    --disable-javascript \
    --disable-default-apps \
    --disable-background-timer-throttling \
    --disable-backgrounding-occluded-windows \
    --disable-renderer-backgrounding \
    --disable-features=TranslateUI \
    --disable-ipc-flooding-protection \
    --user-data-dir=/tmp/chrome-debug \
    --display=:99 \
    --window-size=1024,768 \
    --virtual-time-budget=5000 