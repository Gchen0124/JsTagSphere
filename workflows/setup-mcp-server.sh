#!/bin/bash
# Setup CapCut MCP Server for Claude Desktop

echo "========================================="
echo "CapCut MCP Server Setup for Claude Desktop"
echo "========================================="
echo ""

CAPCUT_DIR="$HOME/CapCutAPI"

# Check if CapCut API exists
if [ ! -d "$CAPCUT_DIR" ]; then
    echo "❌ CapCut API not found at $CAPCUT_DIR"
    echo "   Please install it first"
    exit 1
fi

cd "$CAPCUT_DIR"

# Create MCP virtual environment
echo "📦 Creating MCP virtual environment..."
python3 -m venv venv-mcp
source venv-mcp/bin/activate

# Install MCP dependencies
echo "📥 Installing MCP dependencies..."
if [ -f "requirements-mcp.txt" ]; then
    pip install -r requirements-mcp.txt
else
    echo "⚠️  requirements-mcp.txt not found"
    echo "   Installing basic requirements..."
    pip install -r requirements.txt
fi

echo ""
echo "✅ MCP server setup complete!"
echo ""
echo "========================================="
echo "Next Steps: Configure Claude Desktop"
echo "========================================="
echo ""
echo "1. Open Claude Desktop settings"
echo "2. Go to 'Developer' → 'Edit Config'"
echo "3. Add this configuration:"
echo ""
cat << 'EOF'
{
  "mcpServers": {
    "capcut-api": {
      "command": "python3",
      "args": ["mcp_server.py"],
      "cwd": "$HOME/CapCutAPI",
      "env": {
        "PYTHONPATH": "$HOME/CapCutAPI"
      }
    }
  }
}
EOF
echo ""
echo "4. Replace \$HOME with your actual home directory:"
echo "   $(echo $HOME)"
echo ""
echo "5. Restart Claude Desktop"
echo ""
echo "========================================="
echo "Testing MCP Connection"
echo "========================================="
echo ""
echo "In Claude Desktop, try asking:"
echo '  "Create a CapCut draft with width 1920 and height 1080"'
echo ""
echo "Claude will use the MCP server to execute the command!"
echo ""
