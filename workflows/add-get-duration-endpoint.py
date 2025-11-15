#!/usr/bin/env python3
"""
Add GET_DURATION endpoint to CapCut API Server
This script patches capcut_server.py to add a /get_duration endpoint
"""

import os
import sys

ENDPOINT_CODE = '''
@app.route('/get_duration', methods=['POST'])
def get_duration_endpoint():
    """Get video duration via FFprobe"""
    try:
        data = request.get_json()
        video_url = data.get('video_url')

        if not video_url:
            return jsonify({"success": False, "error": "video_url is required"})

        # Import get_video_duration function
        from get_duration_impl import get_video_duration

        result = get_video_duration(video_url)
        return jsonify(result)

    except Exception as e:
        return jsonify({
            "success": False,
            "error": f"Error getting video duration: {str(e)}"
        })
'''

def patch_capcut_server():
    """Add /get_duration endpoint to capcut_server.py"""

    capcut_dir = os.path.expanduser("~/CapCutAPI")
    server_file = os.path.join(capcut_dir, "capcut_server.py")

    if not os.path.exists(server_file):
        print(f"❌ Error: {server_file} not found")
        print(f"   Please ensure CapCut API is installed at {capcut_dir}")
        return False

    # Read the current server file
    with open(server_file, 'r', encoding='utf-8') as f:
        content = f.read()

    # Check if endpoint already exists
    if '/get_duration' in content:
        print("✅ /get_duration endpoint already exists")
        return True

    # Find a good place to insert (before if __name__ == '__main__')
    if "if __name__ == '__main__':" in content:
        parts = content.split("if __name__ == '__main__':")
        new_content = parts[0] + ENDPOINT_CODE + "\n\nif __name__ == '__main__':" + parts[1]
    else:
        # Append to end
        new_content = content + "\n\n" + ENDPOINT_CODE

    # Backup original file
    backup_file = server_file + ".backup"
    with open(backup_file, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"📦 Backup created: {backup_file}")

    # Write patched file
    with open(server_file, 'w', encoding='utf-8') as f:
        f.write(new_content)

    print("✅ Successfully added /get_duration endpoint to capcut_server.py")
    print("")
    print("⚠️  IMPORTANT: Restart the CapCut API server for changes to take effect")
    print("   1. Press Ctrl+C to stop the server")
    print("   2. Run: python capcut_server.py")
    print("")
    print("Test the endpoint with:")
    print('   curl -X POST http://localhost:9000/get_duration \\')
    print('     -H "Content-Type: application/json" \\')
    print('     -d \'{"video_url": "https://example.com/video.mp4"}\'')

    return True

if __name__ == "__main__":
    success = patch_capcut_server()
    sys.exit(0 if success else 1)
