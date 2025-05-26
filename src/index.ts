#!/usr/bin/env node

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";
import CDP from "chrome-remote-interface";

interface ChromeConnection {
  client: any;
  targetId?: string;
}

class ChromeDevToolsMCPServer {
  private server: Server;
  private connections: Map<string, ChromeConnection> = new Map();

  constructor() {
    this.server = new Server({
      name: "chrome-devtools-mcp-server",
      version: "0.1.0",
      capabilities: {
        tools: {},
      },
    });

    this.setupToolHandlers();
    this.setupErrorHandling();
  }

  private setupErrorHandling() {
    this.server.onerror = (error) => {
      console.error("[MCP Error]", error);
    };

    process.on("SIGINT", async () => {
      await this.cleanup();
      process.exit(0);
    });
  }

  private async cleanup() {
    for (const [id, connection] of this.connections) {
      try {
        if (connection.client) {
          await connection.client.close();
        }
      } catch (error) {
        console.error(`Error closing connection ${id}:`, error);
      }
    }
    this.connections.clear();
  }

  private setupToolHandlers() {
    this.server.setRequestHandler(ListToolsRequestSchema, async () => {
      return {
        tools: [
          {
            name: "connect_chrome",
            description: "Connect to a Chrome DevTools instance",
            inputSchema: {
              type: "object",
              properties: {
                host: {
                  type: "string",
                  description: "Chrome DevTools host (default: localhost)",
                  default: "localhost",
                },
                port: {
                  type: "number",
                  description: "Chrome DevTools port (default: 9222)",
                  default: 9222,
                },
                connectionId: {
                  type: "string",
                  description: "Unique identifier for this connection",
                  default: "default",
                },
              },
            },
          },
          {
            name: "list_tabs",
            description: "List all available browser tabs/targets",
            inputSchema: {
              type: "object",
              properties: {
                connectionId: {
                  type: "string",
                  description: "Connection ID to use",
                  default: "default",
                },
              },
            },
          },
          {
            name: "navigate_to_url",
            description: "Navigate to a specific URL",
            inputSchema: {
              type: "object",
              properties: {
                url: {
                  type: "string",
                  description: "URL to navigate to",
                },
                connectionId: {
                  type: "string",
                  description: "Connection ID to use",
                  default: "default",
                },
              },
              required: ["url"],
            },
          },
          {
            name: "execute_javascript",
            description: "Execute JavaScript code in the browser context",
            inputSchema: {
              type: "object",
              properties: {
                code: {
                  type: "string",
                  description: "JavaScript code to execute",
                },
                connectionId: {
                  type: "string",
                  description: "Connection ID to use",
                  default: "default",
                },
              },
              required: ["code"],
            },
          },
          {
            name: "get_page_content",
            description: "Get the HTML content of the current page",
            inputSchema: {
              type: "object",
              properties: {
                connectionId: {
                  type: "string",
                  description: "Connection ID to use",
                  default: "default",
                },
              },
            },
          },
          {
            name: "take_screenshot",
            description: "Take a screenshot of the current page",
            inputSchema: {
              type: "object",
              properties: {
                format: {
                  type: "string",
                  enum: ["png", "jpeg"],
                  description: "Screenshot format",
                  default: "png",
                },
                quality: {
                  type: "number",
                  description: "JPEG quality (0-100, only for JPEG format)",
                  minimum: 0,
                  maximum: 100,
                  default: 80,
                },
                connectionId: {
                  type: "string",
                  description: "Connection ID to use",
                  default: "default",
                },
              },
            },
          },
          {
            name: "get_network_requests",
            description: "Get network requests made by the page",
            inputSchema: {
              type: "object",
              properties: {
                connectionId: {
                  type: "string",
                  description: "Connection ID to use",
                  default: "default",
                },
              },
            },
          },
          {
            name: "get_console_logs",
            description: "Get console logs from the browser",
            inputSchema: {
              type: "object",
              properties: {
                connectionId: {
                  type: "string",
                  description: "Connection ID to use",
                  default: "default",
                },
              },
            },
          },
          {
            name: "set_device_emulation",
            description: "Emulate a mobile device or set custom viewport",
            inputSchema: {
              type: "object",
              properties: {
                width: {
                  type: "number",
                  description: "Viewport width",
                },
                height: {
                  type: "number",
                  description: "Viewport height",
                },
                deviceScaleFactor: {
                  type: "number",
                  description: "Device scale factor",
                  default: 1,
                },
                mobile: {
                  type: "boolean",
                  description: "Whether to emulate mobile device",
                  default: false,
                },
                connectionId: {
                  type: "string",
                  description: "Connection ID to use",
                  default: "default",
                },
              },
              required: ["width", "height"],
            },
          },
          {
            name: "disconnect_chrome",
            description: "Disconnect from Chrome DevTools",
            inputSchema: {
              type: "object",
              properties: {
                connectionId: {
                  type: "string",
                  description: "Connection ID to disconnect",
                  default: "default",
                },
              },
            },
          },
        ],
      };
    });

    this.server.setRequestHandler(CallToolRequestSchema, async (request) => {
      const { name, arguments: args } = request.params;

      try {
        switch (name) {
          case "connect_chrome":
            return await this.connectChrome(args);
          case "list_tabs":
            return await this.listTabs(args);
          case "navigate_to_url":
            return await this.navigateToUrl(args);
          case "execute_javascript":
            return await this.executeJavaScript(args);
          case "get_page_content":
            return await this.getPageContent(args);
          case "take_screenshot":
            return await this.takeScreenshot(args);
          case "get_network_requests":
            return await this.getNetworkRequests(args);
          case "get_console_logs":
            return await this.getConsoleLogs(args);
          case "set_device_emulation":
            return await this.setDeviceEmulation(args);
          case "disconnect_chrome":
            return await this.disconnectChrome(args);
          default:
            throw new Error(`Unknown tool: ${name}`);
        }
      } catch (error) {
        return {
          content: [
            {
              type: "text",
              text: `Error: ${
                error instanceof Error ? error.message : String(error)
              }`,
            },
          ],
        };
      }
    });
  }

  private async connectChrome(args: any) {
    const { host = "localhost", port = 9222, connectionId = "default" } = args;

    try {
      // Close existing connection if it exists
      if (this.connections.has(connectionId)) {
        await this.disconnectChrome({ connectionId });
      }

      const client = await CDP({ host, port });

      // Enable necessary domains
      await client.Page.enable();
      await client.Runtime.enable();
      await client.Network.enable();
      await client.Console.enable();

      this.connections.set(connectionId, { client });

      return {
        content: [
          {
            type: "text",
            text: `Successfully connected to Chrome DevTools at ${host}:${port} (Connection ID: ${connectionId})`,
          },
        ],
      };
    } catch (error) {
      throw new Error(
        `Failed to connect to Chrome DevTools: ${
          error instanceof Error ? error.message : String(error)
        }`
      );
    }
  }

  private async listTabs(_args: any) {
    try {
      const targets = await CDP.List({ host: "localhost", port: 9222 });
      return {
        content: [
          {
            type: "text",
            text: JSON.stringify(targets, null, 2),
          },
        ],
      };
    } catch (error) {
      throw new Error(
        `Failed to list tabs: ${
          error instanceof Error ? error.message : String(error)
        }`
      );
    }
  }

  private async navigateToUrl(args: any) {
    const { url, connectionId = "default" } = args;
    const connection = this.connections.get(connectionId);

    if (!connection) {
      throw new Error(`No connection found with ID: ${connectionId}`);
    }

    try {
      await connection.client.Page.navigate({ url });
      await connection.client.Page.loadEventFired();

      return {
        content: [
          {
            type: "text",
            text: `Successfully navigated to: ${url}`,
          },
        ],
      };
    } catch (error) {
      throw new Error(
        `Failed to navigate to URL: ${
          error instanceof Error ? error.message : String(error)
        }`
      );
    }
  }

  private async executeJavaScript(args: any) {
    const { code, connectionId = "default" } = args;
    const connection = this.connections.get(connectionId);

    if (!connection) {
      throw new Error(`No connection found with ID: ${connectionId}`);
    }

    try {
      const result = await connection.client.Runtime.evaluate({
        expression: code,
        returnByValue: true,
      });

      return {
        content: [
          {
            type: "text",
            text: JSON.stringify(result, null, 2),
          },
        ],
      };
    } catch (error) {
      throw new Error(
        `Failed to execute JavaScript: ${
          error instanceof Error ? error.message : String(error)
        }`
      );
    }
  }

  private async getPageContent(args: any) {
    const { connectionId = "default" } = args;
    const connection = this.connections.get(connectionId);

    if (!connection) {
      throw new Error(`No connection found with ID: ${connectionId}`);
    }

    try {
      const result = await connection.client.Runtime.evaluate({
        expression: "document.documentElement.outerHTML",
        returnByValue: true,
      });

      return {
        content: [
          {
            type: "text",
            text: result.result.value,
          },
        ],
      };
    } catch (error) {
      throw new Error(
        `Failed to get page content: ${
          error instanceof Error ? error.message : String(error)
        }`
      );
    }
  }

  private async takeScreenshot(args: any) {
    const { format = "png", quality = 80, connectionId = "default" } = args;
    const connection = this.connections.get(connectionId);

    if (!connection) {
      throw new Error(`No connection found with ID: ${connectionId}`);
    }

    try {
      const screenshot = await connection.client.Page.captureScreenshot({
        format,
        quality: format === "jpeg" ? quality : undefined,
      });

      return {
        content: [
          {
            type: "text",
            text: `Screenshot captured (base64): ${screenshot.data.substring(
              0,
              100
            )}...`,
          },
        ],
      };
    } catch (error) {
      throw new Error(
        `Failed to take screenshot: ${
          error instanceof Error ? error.message : String(error)
        }`
      );
    }
  }

  private async getNetworkRequests(args: any) {
    const { connectionId = "default" } = args;
    const connection = this.connections.get(connectionId);

    if (!connection) {
      throw new Error(`No connection found with ID: ${connectionId}`);
    }

    // This is a simplified example - in a real implementation,
    // you'd want to collect network events over time
    return {
      content: [
        {
          type: "text",
          text: "Network monitoring requires event collection. Enable Network domain and listen for requestWillBeSent events.",
        },
      ],
    };
  }

  private async getConsoleLogs(args: any) {
    const { connectionId = "default" } = args;
    const connection = this.connections.get(connectionId);

    if (!connection) {
      throw new Error(`No connection found with ID: ${connectionId}`);
    }

    // This is a simplified example - in a real implementation,
    // you'd want to collect console events over time
    return {
      content: [
        {
          type: "text",
          text: "Console log monitoring requires event collection. Listen for Runtime.consoleAPICalled events.",
        },
      ],
    };
  }

  private async setDeviceEmulation(args: any) {
    const {
      width,
      height,
      deviceScaleFactor = 1,
      mobile = false,
      connectionId = "default",
    } = args;
    const connection = this.connections.get(connectionId);

    if (!connection) {
      throw new Error(`No connection found with ID: ${connectionId}`);
    }

    try {
      await connection.client.Emulation.setDeviceMetricsOverride({
        width,
        height,
        deviceScaleFactor,
        mobile,
      });

      return {
        content: [
          {
            type: "text",
            text: `Device emulation set: ${width}x${height}, scale: ${deviceScaleFactor}, mobile: ${mobile}`,
          },
        ],
      };
    } catch (error) {
      throw new Error(
        `Failed to set device emulation: ${
          error instanceof Error ? error.message : String(error)
        }`
      );
    }
  }

  private async disconnectChrome(args: any) {
    const { connectionId = "default" } = args;
    const connection = this.connections.get(connectionId);

    if (!connection) {
      return {
        content: [
          {
            type: "text",
            text: `No connection found with ID: ${connectionId}`,
          },
        ],
      };
    }

    try {
      await connection.client.close();
      this.connections.delete(connectionId);

      return {
        content: [
          {
            type: "text",
            text: `Successfully disconnected from Chrome DevTools (Connection ID: ${connectionId})`,
          },
        ],
      };
    } catch (error) {
      throw new Error(
        `Failed to disconnect: ${
          error instanceof Error ? error.message : String(error)
        }`
      );
    }
  }

  async run() {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
    console.error("Chrome DevTools MCP server running on stdio");
  }
}

const server = new ChromeDevToolsMCPServer();
server.run().catch(console.error);
