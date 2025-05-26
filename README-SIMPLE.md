# Chrome DevTools MCP Server - Simple Setup Guide

> **For Non-Technical Users**: This tool lets you control Chrome browser through Claude Desktop with simple voice commands!

## What This Does

- **Control Chrome with Claude**: Say "Navigate to google.com" and Claude will open Google in Chrome
- **Take Screenshots**: Ask Claude to capture what's on your screen
- **Run Website Tests**: Check if websites work properly
- **Mobile Testing**: See how websites look on phones/tablets

## Super Easy Setup (5 Minutes)

### Step 1: Download This Tool

1. Click the green "Code" button above
2. Select "Download ZIP"
3. Unzip the file to your Desktop

### Step 2: One-Click Setup

1. Open the folder you just unzipped
2. **On Mac**: Double-click `easy-setup.sh`
3. **On Windows**: Double-click `easy-setup.bat` (coming soon)
4. Follow the prompts - it does everything automatically!

### Step 3: Restart Claude Desktop

- Close Claude Desktop completely
- Open it again
- You're ready to go!

## How to Use

Just talk to Claude naturally:

- **"Connect to my Chrome browser"**
- **"Navigate to amazon.com"**
- **"Take a screenshot of this page"**
- **"Make the browser look like an iPhone"**
- **"Execute some JavaScript to click the login button"**

## Troubleshooting

### "Docker not found" error

- The setup script will guide you to install Docker Desktop
- It's free and safe - just follow the download link provided

### "Claude can't connect" error

- Make sure you restarted Claude Desktop after setup
- Try saying "Connect to Chrome" again

### Still having issues?

- Run: `./start-docker.sh status` to check if everything is running
- Look for the green checkmarks ✅

## What Gets Installed

- **Docker Desktop**: Safely runs the Chrome browser in a container
- **Chrome DevTools Server**: The tool that connects Claude to Chrome
- **Claude Configuration**: Automatically sets up Claude to use the tool

## Uninstalling

To remove everything:

1. Run: `./start-docker.sh clean`
2. Uninstall Docker Desktop (optional)
3. Delete the folder from your Desktop

## Need Help?

- Check the troubleshooting section above
- Look at the full technical README.md for advanced options
- The setup is designed to "just work" - if it doesn't, something unusual happened

---

**Technical users**: See `README.md` for advanced configuration options.
