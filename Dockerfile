# Use Node.js base image with Chrome support
FROM node:20-bullseye

# Set platform-specific variables
ARG TARGETPLATFORM
ARG BUILDPLATFORM

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    gnupg \
    ca-certificates \
    apt-transport-https \
    software-properties-common \
    xvfb \
    x11vnc \
    fluxbox \
    supervisor \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libatspi2.0-0 \
    libcairo2 \
    libcups2 \
    libcurl4 \
    libdbus-1-3 \
    libexpat1 \
    libgbm1 \
    libglib2.0-0 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libpango-1.0-0 \
    libudev1 \
    libvulkan1 \
    libx11-6 \
    libxcb1 \
    libxcomposite1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxkbcommon0 \
    libxrandr2 \
    libxss1 \
    fonts-liberation \
    && rm -rf /var/lib/apt/lists/*

# Install Google Chrome based on architecture
RUN if [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
        # For ARM64, use Chromium
        apt-get update && \
        apt-get install -y chromium && \
        ln -sf /usr/bin/chromium /usr/bin/google-chrome && \
        rm -rf /var/lib/apt/lists/*; \
    else \
        # For AMD64, use Google Chrome
        wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - && \
        echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list && \
        apt-get update && \
        apt-get install -y google-chrome-stable && \
        rm -rf /var/lib/apt/lists/*; \
    fi

# Create app directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install all dependencies (including dev dependencies for build)
RUN npm ci

# Copy source code
COPY . .

# Build the TypeScript code
RUN npm run build

# Remove dev dependencies to reduce image size
RUN npm prune --production

# Create directories for Chrome
RUN mkdir -p /tmp/chrome-debug

# Create supervisor configuration
RUN mkdir -p /etc/supervisor/conf.d

# Copy supervisor configuration
COPY docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Create startup scripts
COPY docker/start-chrome.sh /usr/local/bin/start-chrome.sh
COPY docker/start-mcp.sh /usr/local/bin/start-mcp.sh

# Make scripts executable
RUN chmod +x /usr/local/bin/start-chrome.sh /usr/local/bin/start-mcp.sh

# Expose ports
EXPOSE 9222 5900

# Set environment variables
ENV DISPLAY=:99
ENV NODE_ENV=production

# Set Chrome binary path based on what was installed
RUN if [ -f /usr/bin/google-chrome ]; then \
        echo "ENV CHROME_BIN=/usr/bin/google-chrome" >> /etc/environment; \
    elif [ -f /usr/bin/chromium-browser ]; then \
        echo "ENV CHROME_BIN=/usr/bin/chromium-browser" >> /etc/environment; \
    fi

ENV CHROME_BIN=/usr/bin/google-chrome

# Start supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"] 