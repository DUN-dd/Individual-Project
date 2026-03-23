# GDA1 MCP Server

MCP (Model Context Protocol) server for **Glorious Deliverance Agency 1**. This allows Claude Desktop and other MCP-compatible AI clients to observe and control the game.

## Quick Setup

### 1. Install uv (Python package manager)

**Windows (PowerShell):**
```powershell
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
```

**macOS/Linux:**
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### 2. Configure Claude Desktop

Open Claude Desktop config file:

**Windows:**
```powershell
code $env:AppData\Claude\claude_desktop_config.json
```

**macOS:**
```bash
code ~/Library/Application\ Support/Claude/claude_desktop_config.json
```

Add this configuration (replace the path with your actual path):

```json
{
  "mcpServers": {
    "gda1-game": {
      "command": "uv",
      "args": [
        "--directory",
        "C:\\Users\\YOUR_USERNAME\\path\\to\\Individual-Project\\1.Codebase\\mcp",
        "run",
        "gda1_server.py"
      ]
    }
  }
}
```

> **Note:** On Windows, use double backslashes (`\\`) in the path.

### 3. Start the Game

1. Launch GDA1 in Godot
2. Go to **Settings** → Enable **AI Agent Server**
3. Restart Claude Desktop

### 4. Use in Claude Desktop

Once configured, you can ask Claude to:

- "What's happening in the game?"
- "Select choice 0"
- "Start a new mission"
- "Enable auto-play mode"

## Available Tools

| Tool | Description |
|------|-------------|
| `get_game_state` | Get current game state (story, choices, stats) |
| `select_choice` | Select a dialogue choice by ID |
| `start_mission` | Start a new mission |
| `submit_prayer` | Submit a prayer text |
| `set_auto_mode` | Enable/disable auto-play |
| `connect_to_game` | Reconnect to the game server |

## Troubleshooting

### Server not showing in Claude Desktop

1. Check the config file path is absolute
2. Make sure `uv` is installed and in PATH
3. Restart Claude Desktop completely (quit from system tray)

### Connection failed

1. Make sure the game is running
2. Enable "AI Agent Server" in game settings
3. Check the default ports (WebSocket: 9876, TCP: 9877)

### Check logs

**Windows:**
```powershell
Get-Content $env:AppData\Claude\logs\mcp*.log -Tail 20
```

**macOS:**
```bash
tail -n 20 -f ~/Library/Logs/Claude/mcp*.log
```

## Manual Testing

You can also test the MCP server directly:

```bash
cd mcp
uv run gda1_server.py
```

This will start the server in STDIO mode for testing.
