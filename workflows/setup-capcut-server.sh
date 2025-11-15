#!/bin/bash
# CapCut API Server Setup Script

echo "========================================="
echo "CapCut API Server Setup"
echo "========================================="
echo ""

# Check if CapCut API is already cloned
if [ -d "$HOME/CapCutAPI" ]; then
    echo "✅ CapCut API directory already exists at $HOME/CapCutAPI"
    cd "$HOME/CapCutAPI"
else
    echo "📥 Cloning CapCut API repository..."
    cd "$HOME"
    git clone https://github.com/sun-guannan/CapCutAPI.git
    cd CapCutAPI
    echo "✅ Repository cloned"
fi

echo ""

# Check Python version
echo "🔍 Checking Python version..."
PYTHON_VERSION=$(python3 --version 2>&1)
echo "   $PYTHON_VERSION"

if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is not installed"
    echo "   Please install Python 3.10+ first:"
    echo "   - macOS: brew install python@3.11"
    echo "   - Linux: sudo apt install python3.11"
    exit 1
fi

echo ""

# Check if virtual environment exists
if [ -d "venv" ]; then
    echo "✅ Virtual environment already exists"
else
    echo "🔨 Creating virtual environment..."
    python3 -m venv venv
    echo "✅ Virtual environment created"
fi

echo ""

# Activate virtual environment and install dependencies
echo "📦 Installing dependencies..."
source venv/bin/activate

if [ -f "requirements.txt" ]; then
    pip install -q -r requirements.txt
    echo "✅ Dependencies installed"
else
    echo "❌ requirements.txt not found"
    exit 1
fi

echo ""
echo "========================================="
echo "✅ Setup Complete!"
echo "========================================="
echo ""
echo "To start the CapCut API server, run:"
echo ""
echo "   cd $HOME/CapCutAPI"
echo "   source venv/bin/activate"
echo "   python capcut_server.py"
echo ""
echo "Or use the start script:"
echo "   bash ~/start-capcut-server.sh"
echo ""
