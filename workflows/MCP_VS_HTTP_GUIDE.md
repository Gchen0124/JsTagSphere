# CapCut API: MCP vs HTTP - Complete Guide

## Overview

The CapCut API provides **two different interfaces** for the same functionality:

```
┌─────────────────────────────────────────────────────────────┐
│                     CapCut API Core                         │
│  (Video editing, draft creation, effects, etc.)             │
└───────────────┬─────────────────────┬───────────────────────┘
                │                     │
        ┌───────▼────────┐    ┌──────▼───────┐
        │  HTTP Server   │    │  MCP Server  │
        │  (Port 9000)   │    │  (stdio)     │
        └───────┬────────┘    └──────┬───────┘
                │                     │
        ┌───────▼────────┐    ┌──────▼──────────┐
        │  n8n Workflows │    │  Claude Desktop │
        │  REST Clients  │    │  AI Assistants  │
        │  curl/Postman  │    │  MCP Clients    │
        └────────────────┘    └─────────────────┘
```

## HTTP API (What We're Using)

### Communication Protocol
- **REST HTTP endpoints**
- JSON request/response
- Standard HTTP methods (GET, POST)
- Runs on `http://localhost:9000`

### Best For
✅ n8n workflows (what you're building)
✅ Web applications
✅ Automation scripts
✅ REST API clients
✅ Integration with other HTTP services

### Example Usage
```bash
curl -X POST http://localhost:9000/add_video \
  -H "Content-Type: application/json" \
  -d '{
    "draft_id": "abc123",
    "video_url": "https://...",
    "start": 0,
    "target_start": 0
  }'
```

### Starting the Server
```bash
cd ~/CapCutAPI
python capcut_server.py
```

## MCP Server (Model Context Protocol)

### Communication Protocol
- **JSON-RPC 2.0 over stdio**
- Reads from stdin, writes to stdout
- Designed for AI assistant integration
- No HTTP ports needed

### Best For
✅ Claude Desktop integration
✅ AI agent automation
✅ Natural language video editing
✅ Conversational interfaces
✅ Direct AI assistant control

### Example Usage (in Claude Desktop)
```
You: "Create a CapCut draft with 1920x1080 resolution"

Claude: [Calls create_draft tool via MCP]
        "I've created a new draft with ID: dfd_cat_1763211331_abc123"

You: "Add this video: https://example.com/video.mp4 at position 0"

Claude: [Calls add_video tool via MCP]
        "I've added the video to your draft!"
```

### Starting the Server
The MCP server is started automatically by Claude Desktop when configured.

---

## Detailed Comparison

| Feature | HTTP API | MCP Server |
|---------|----------|------------|
| **Protocol** | HTTP/REST | JSON-RPC over stdio |
| **Port** | 9000 | None (stdio) |
| **Best Client** | n8n, curl, Postman | Claude Desktop, AI agents |
| **Authentication** | None (local) | None (local) |
| **Response Format** | JSON via HTTP | JSON via stdout |
| **Error Handling** | HTTP status codes | JSON-RPC error objects |
| **Setup Complexity** | Simple (just run server) | Moderate (config file needed) |
| **Natural Language** | No | Yes (via AI assistant) |
| **Automation** | Via HTTP requests | Via AI conversation |
| **Multiple Clients** | Yes (many connections) | Typically one (Claude Desktop) |

---

## When to Use Each

### Use HTTP API When:
- Building n8n workflows ✅ **Your current project**
- Creating web applications
- Integrating with other HTTP services
- Need multiple simultaneous connections
- Want direct programmatic control

### Use MCP Server When:
- Using Claude Desktop for video editing
- Want natural language control
- Prefer conversational interface
- Building AI agent workflows
- Testing ideas quickly via chat

---

## Can You Use Both?

**YES!** You can run both simultaneously:

```bash
# Terminal 1: HTTP Server
cd ~/CapCutAPI
python capcut_server.py
# Running on http://localhost:9000

# Terminal 2: MCP Server (auto-started by Claude Desktop)
# Configured in Claude Desktop → Developer → Edit Config
```

Both interfaces access the same underlying CapCut functionality!

---

## Setting Up MCP for Claude Desktop

### Step 1: Prepare the Environment

```bash
cd ~/CapCutAPI
python3 -m venv venv-mcp
source venv-mcp/bin/activate
pip install -r requirements-mcp.txt
```

### Step 2: Configure Claude Desktop

1. Open **Claude Desktop**
2. Go to **Settings** → **Developer** → **Edit Config**
3. Add this configuration:

```json
{
  "mcpServers": {
    "capcut-api": {
      "command": "python3",
      "args": ["mcp_server.py"],
      "cwd": "/Users/YOUR_USERNAME/CapCutAPI",
      "env": {
        "PYTHONPATH": "/Users/YOUR_USERNAME/CapCutAPI"
      }
    }
  }
}
```

**Important:** Replace `/Users/YOUR_USERNAME/CapCutAPI` with your actual path!

To find your path:
```bash
cd ~/CapCutAPI && pwd
```

### Step 3: Restart Claude Desktop

Close and reopen Claude Desktop completely.

### Step 4: Test the Connection

In Claude Desktop, try:

```
Create a CapCut draft with width 1920 and height 1080
```

Claude should respond with a draft_id if MCP is working!

---

## MCP Tools Available

Once configured, Claude Desktop can use these tools:

| Tool | Description |
|------|-------------|
| `create_draft` | Initialize new video project |
| `add_video` | Add video clips with effects |
| `add_audio` | Add audio tracks |
| `add_image` | Add images with animations |
| `add_text` | Add styled text overlays |
| `add_subtitle` | Add SRT subtitles |
| `add_effect` | Apply visual effects |
| `add_sticker` | Add sticker elements |
| `add_video_keyframe` | Create animations |
| `get_video_duration` | Get video length |
| `save_draft` | Save project |

---

## Example Workflows

### HTTP API (n8n) Workflow
```javascript
// 1. Create draft
POST http://localhost:9000/create_draft
{ "width": 1920, "height": 1080 }

// 2. Add videos
POST http://localhost:9000/add_video
{
  "draft_id": "abc123",
  "video_url": "https://...",
  "target_start": 0
}

// 3. Save
POST http://localhost:9000/save_draft
{
  "draft_id": "abc123",
  "draft_folder": "my_project"
}
```

### MCP (Claude Desktop) Workflow
```
You: Create a video project with these 3 videos:
     1. https://example.com/intro.mp4
     2. https://example.com/main.mp4
     3. https://example.com/outro.mp4

Claude: [Uses MCP tools automatically]
        I'll create a draft and add those videos sequentially.

        1. Created draft: dfd_cat_1763211331_abc123
        2. Added intro.mp4 at 0s
        3. Added main.mp4 at 5s
        4. Added outro.mp4 at 35s
        5. Saved draft as "merged_videos"

        Your draft is ready! The ID is: dfd_cat_1763211331_abc123

You: Add a text overlay that says "My Video" at the beginning

Claude: [Calls add_text via MCP]
        Done! Added "My Video" text at the start.
```

---

## For Your n8n Workflow

### Recommendation: **Stick with HTTP API**

**Why?**
- ✅ n8n is built for HTTP requests
- ✅ Direct programmatic control
- ✅ Easy to debug (can use curl)
- ✅ Better for automation
- ✅ What you've already built works!

**MCP would be useful if:**
- You want to prototype workflows conversationally in Claude Desktop first
- You want to test CapCut API features by asking Claude
- You're building an AI agent that controls video editing

### Hybrid Approach

You could use **both**:

1. **Develop** in Claude Desktop (MCP)
   - "Claude, test merging these 3 videos"
   - Quick prototyping via natural language

2. **Automate** with n8n (HTTP)
   - Production workflow
   - Scheduled execution
   - Integration with Google Sheets

---

## Troubleshooting

### HTTP API Issues

**Server won't start:**
```bash
cd ~/CapCutAPI
python capcut_server.py
```
Check if port 9000 is already in use:
```bash
lsof -i :9000
```

### MCP Issues

**Claude Desktop doesn't see tools:**
1. Check config file syntax (valid JSON)
2. Verify paths are absolute (not ~)
3. Restart Claude Desktop completely
4. Check Claude Desktop logs

**MCP server crashes:**
1. Check Python version (need 3.10+)
2. Verify all dependencies installed
3. Check `PYTHONPATH` in config

---

## Advantages of Each

### HTTP API Advantages
- Industry standard
- Wide tool support
- Easy debugging
- Multiple simultaneous clients
- Better for production

### MCP Advantages
- Natural language control
- Conversational workflow
- Quick prototyping
- AI-assisted editing
- Better for exploration

---

## Final Recommendation

**For your n8n video merger workflow:**

✅ **Keep using HTTP API** - It's perfect for your use case

**Additionally, set up MCP for:**
- Quick testing of CapCut features
- Prototyping new workflow ideas
- Exploring the API conversationally

**Example workflow:**
1. **Prototype in Claude Desktop** (MCP)
   - "Claude, how do I add a transition between videos?"
   - Test different approaches conversationally

2. **Implement in n8n** (HTTP)
   - Take what you learned
   - Build the production workflow
   - Automate with Google Sheets

---

## Resources

- **HTTP API Reference**: `CAPCUT_API_REFERENCE.md`
- **n8n Workflow**: `capcut-video-merger.json`
- **MCP Setup Script**: `setup-mcp-server.sh`
- **MCP Config Template**: `claude-desktop-mcp-config.json`

---

## Questions?

**Q: Can I use MCP in n8n?**
A: Technically yes with custom nodes, but HTTP is simpler and better.

**Q: Is MCP faster than HTTP?**
A: No, they use the same underlying code. MCP is about interface, not speed.

**Q: Can I run both servers at once?**
A: Yes! They don't conflict. HTTP uses port 9000, MCP uses stdio.

**Q: Which should I learn first?**
A: HTTP API - it's more versatile and what you're already using!

---

**Version**: 1.0
**Last Updated**: 2025-11-15
