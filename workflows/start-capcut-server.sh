#!/bin/bash
# Start CapCut API Server

CAPCUT_DIR="$HOME/CapCutAPI"

if [ ! -d "$CAPCUT_DIR" ]; then
    echo "❌ CapCut API not found at $CAPCUT_DIR"
    echo "   Run setup first: bash setup-capcut-server.sh"
    exit 1
fi

cd "$CAPCUT_DIR"

echo "========================================="
echo "Starting CapCut API Server"
echo "========================================="
echo ""
echo "📍 Location: $CAPCUT_DIR"
echo "🌐 Server will run on: http://localhost:9001"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""
echo "========================================="
echo ""

# Activate virtual environment
source venv/bin/activate

# Start the server
python capcut_server.py
