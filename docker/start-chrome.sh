#!/bin/bash

# Wait for Xvfb to be ready
sleep 2

# Detect which browser is available
if [ -f /usr/bin/google-chrome ]; then
    CHROME_BIN="/usr/bin/google-chrome"
elif [ -f /usr/bin/chromium ]; then
    CHROME_BIN="/usr/bin/chromium"
elif [ -f /usr/bin/chromium-browser ]; then
    CHROME_BIN="/usr/bin/chromium-browser"
else
    echo "No Chrome or Chromium browser found!"
    exit 1
fi

echo "Starting browser: $CHROME_BIN"

# Start Chrome/Chromium with remote debugging enabled
exec $CHROME_BIN \
    --remote-debugging-port=9222 \
    --remote-debugging-address=0.0.0.0 \
    --no-first-run \
    --no-default-browser-check \
    --no-sandbox \
    --disable-dev-shm-usage \
    --disable-gpu \
    --disable-extensions \
    --disable-plugins \
    --disable-default-apps \
    --disable-background-timer-throttling \
    --disable-backgrounding-occluded-windows \
    --disable-renderer-backgrounding \
    --disable-features=TranslateUI \
    --disable-ipc-flooding-protection \
    --disable-web-security \
    --disable-features=VizDisplayCompositor \
    --user-data-dir=/tmp/chrome-debug \
    --display=:99 \
    --window-size=1024,768 \
    --headless 