# CapCut Video Merger n8n Workflow

This n8n workflow automates the process of merging multiple videos using the CapCut API. It reads video URLs from Google Sheets, creates a CapCut draft, merges the videos, and downloads the final result.

## Features

- **Google Sheets Integration**: Reads video URLs and timing information from Google Sheets
- **Automated Video Merging**: Combines multiple videos into a single draft using CapCut API
- **Draft Generation**: Creates a CapCut draft with customizable dimensions (1920x1080 by default)
- **Status Polling**: Automatically monitors the rendering progress
- **Automatic Download**: Downloads the final merged video once processing is complete
- **Timestamped Output**: Saves videos with unique timestamps to prevent overwrites

## Prerequisites

### 1. CapCut API Server

You need to have the CapCut API server running locally. Follow these steps:

```bash
# Clone the CapCut API repository
git clone https://github.com/sun-guannan/CapCutAPI.git
cd CapCutAPI

# Install dependencies
pip install -r requirements.txt

# Start the server (default port: 9001)
python capcut_server.py
```

The server will be available at `http://localhost:9001`

### 2. n8n Installation

Install n8n if you haven't already:

```bash
# Via npm
npm install n8n -g

# Or via Docker
docker run -it --rm \
  --name n8n \
  -p 5678:5678 \
  -v ~/.n8n:/home/node/.n8n \
  n8nio/n8n
```

### 3. Google Sheets Setup

Create a Google Sheet with the following structure:

| video_url | start_time | end_time |
|-----------|------------|----------|
| https://example.com/video1.mp4 | 0 | 10 |
| https://example.com/video2.mp4 | 0 | 15 |
| https://example.com/video3.mp4 | 5 | 20 |

**Column Descriptions:**
- `video_url`: Full URL to the video file (must be accessible)
- `start_time`: Start time in seconds (optional, defaults to 0)
- `end_time`: End time in seconds (optional, defaults to 10)

## Installation

### 1. Import the Workflow into n8n

1. Open n8n in your browser (typically `http://localhost:5678`)
2. Click on **"Workflows"** in the left sidebar
3. Click **"Add Workflow"** → **"Import from File"**
4. Select `capcut-video-merger.json` from this directory
5. The workflow will be imported

### 2. Configure Google Sheets Credentials

1. In the workflow, click on the **"Read Video URLs from Google Sheets"** node
2. Click on **"Credential to connect with"**
3. Select **"Create New Credential"**
4. Choose **"Google Sheets OAuth2 API"**
5. Follow the OAuth setup:
   - Go to [Google Cloud Console](https://console.cloud.google.com/)
   - Create a new project or select an existing one
   - Enable the Google Sheets API
   - Create OAuth 2.0 credentials (Web application)
   - Add `http://localhost:5678/rest/oauth2-credential/callback` as a redirect URI
   - Copy the Client ID and Client Secret to n8n
   - Complete the OAuth flow

### 3. Update Workflow Configuration

Update the following parameters in the workflow:

#### Google Sheets Node
- **documentId**: Replace `YOUR_GOOGLE_SHEET_ID` with your actual Google Sheet ID
  - You can find this in the sheet URL: `https://docs.google.com/spreadsheets/d/{SHEET_ID}/edit`
- **sheetName**: Change from `Sheet1` if your sheet has a different name

#### CapCut API Server URL
If your CapCut API server is not running on `localhost:9001`, update these nodes:
- **Create CapCut Draft**: Update the URL in the HTTP Request node
- **Add Video to Draft**: Update the URL
- **Save CapCut Draft**: Update the URL
- **Poll Draft Status**: Update the URL

#### Video Output Settings
In the **"Create CapCut Draft"** node, you can customize:
- **width**: Video width in pixels (default: 1920)
- **height**: Video height in pixels (default: 1080)

## How to Use

### 1. Prepare Your Google Sheet

Add your video URLs to the Google Sheet with the required columns.

### 2. Start the CapCut API Server

Make sure the CapCut API server is running:

```bash
cd CapCutAPI
python capcut_server.py
```

### 3. Run the Workflow

1. Open the workflow in n8n
2. Click **"Execute Workflow"** or use the manual trigger
3. The workflow will:
   - Read video URLs from Google Sheets
   - Create a new CapCut draft
   - Add each video sequentially with transitions
   - Save the draft and get a task ID
   - Poll for completion status every 10 seconds
   - Download the final merged video
   - Save it to disk with a timestamp

### 4. Find Your Video

The merged video will be saved in n8n's default file directory with the filename:
```
merged_video_YYYY-MM-DD_HH-MM-SS.mp4
```

## Workflow Details

### Node Breakdown

1. **Manual Trigger**: Starts the workflow manually
2. **Read Video URLs from Google Sheets**: Fetches video data from your sheet
3. **Process Video Data**: Formats the data for processing
4. **Create CapCut Draft**: Creates a new draft project (returns `draft_id`)
5. **Extract Draft ID**: Stores the draft ID for subsequent requests
6. **Combine Draft with Videos**: Merges draft info with video data
7. **Loop Through Videos**: Iterates over each video URL
8. **Add Video to Draft**: Adds each video to the draft with fade transitions
9. **Wait Between Videos**: Prevents API overload (1 second delay)
10. **Check If All Videos Added**: Determines when to proceed to saving
11. **Save CapCut Draft**: Initiates server-side processing (returns `task_id`)
12. **Extract Task ID**: Stores the task ID for polling
13. **Wait Before First Poll**: Initial 5-second delay
14. **Poll Draft Status**: Checks if processing is complete
15. **Check If Completed**: Continues polling or proceeds to download
16. **Wait Before Next Poll**: 10-second delay between polls (if not complete)
17. **Extract Video URL**: Gets the final video download URL
18. **Download Merged Video**: Downloads the rendered video file
19. **Save Video to Disk**: Writes the video to the file system
20. **Success Summary**: Returns completion details

### API Endpoints Used

- `POST /create_draft`: Creates a new video project
- `POST /add_video`: Adds a video track to the draft
- `POST /save_draft`: Saves and processes the draft
- `POST /query_draft_status`: Checks processing status

## Customization Options

### Video Transitions

In the **"Add Video to Draft"** node, you can change the transition type:

```json
{
  "transition": "fade"
}
```

Available transitions include: `fade`, `dissolve`, `slide`, `wipe`, etc.
(Run `GET http://localhost:9001/get_transition_types` to see all available types)

### Video Volume

Adjust the volume for each video (0.0 to 1.0):

```json
{
  "volume": 1.0
}
```

### Polling Interval

Change the polling frequency in the **"Wait Before Next Poll"** node:
- Default: 10 seconds
- Recommended range: 5-30 seconds

### Video Output Dimensions

Modify in the **"Create CapCut Draft"** node:
- **1920x1080**: Full HD (16:9)
- **1080x1920**: Vertical/Portrait (9:16) - for TikTok, Instagram Reels
- **3840x2160**: 4K UHD (16:9)

## Troubleshooting

### Issue: "Connection refused" error

**Solution**: Make sure the CapCut API server is running on port 9001

```bash
python capcut_server.py
```

### Issue: Google Sheets authentication fails

**Solution**:
1. Check that your OAuth credentials are correctly configured
2. Ensure the Google Sheets API is enabled in your Google Cloud project
3. Verify the redirect URI matches n8n's callback URL

### Issue: Videos not merging properly

**Solution**:
1. Verify all video URLs are publicly accessible
2. Check that video formats are supported (MP4, MOV, AVI, etc.)
3. Ensure start and end times are valid
4. Check CapCut API server logs for errors

### Issue: Workflow times out during polling

**Solution**:
1. Large videos take longer to process - increase the workflow timeout
2. Check the CapCut API server status
3. Verify the task_id is being passed correctly

### Issue: Downloaded video is corrupted

**Solution**:
1. Check your internet connection
2. Increase the timeout in the "Download Merged Video" node
3. Verify the draft_url is correct and accessible

## Advanced Usage

### Schedule Automatic Runs

Replace the **"Manual Trigger"** node with a **"Cron"** or **"Schedule Trigger"** node to run automatically:

```
Every day at 2 AM: 0 2 * * *
Every hour: 0 * * * *
```

### Add to Cloud Storage

Add a node after **"Save Video to Disk"** to upload to:
- Google Drive
- Dropbox
- AWS S3
- Azure Blob Storage

### Email Notification

Add an email node to get notified when processing completes:
- Gmail
- SendGrid
- SMTP

### Error Handling

Add error handling nodes to:
- Retry failed API calls
- Send alerts on failure
- Log errors to a database

## API Response Examples

### Create Draft Response
```json
{
  "draft_id": "abc123xyz",
  "draft_url": "https://www.install-ai-guider.top/draft/downloader?draft_id=abc123xyz"
}
```

### Save Draft Response
```json
{
  "task_id": "task_456def",
  "status": "processing"
}
```

### Poll Status Response (In Progress)
```json
{
  "task_id": "task_456def",
  "status": "processing",
  "progress": 45
}
```

### Poll Status Response (Completed)
```json
{
  "task_id": "task_456def",
  "status": "completed",
  "draft_url": "https://www.install-ai-guider.top/draft/downloader?draft_id=abc123xyz",
  "video_url": "https://cdn.example.com/merged_video.mp4"
}
```

## Resources

- [CapCut API Repository](https://github.com/sun-guannan/CapCutAPI)
- [n8n Documentation](https://docs.n8n.io/)
- [Google Sheets API](https://developers.google.com/sheets/api)

## License

This workflow is provided as-is under the MIT License.

## Contributing

Feel free to submit issues or pull requests to improve this workflow!

---

**Note**: Make sure you have the necessary rights and permissions to use and merge the videos you're processing.
