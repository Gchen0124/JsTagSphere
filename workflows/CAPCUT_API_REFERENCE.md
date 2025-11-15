# CapCut API Reference - Complete Guide

## ⚠️ CRITICAL: Time Format

**CapCut HTTP API uses SECONDS, NOT microseconds!**

```
✅ CORRECT:   start: 5.5    (5.5 seconds)
❌ WRONG:     start: 5500000 (microseconds)
```

### Why the Confusion?

- **HTTP API Layer**: Accepts SECONDS (e.g., `0.5`, `5.0`, `10.5`)
- **Internal Python Layer**: Converts to microseconds internally (1 sec = 1,000,000 μs)

**Source Evidence:**
```python
# From time_util.py line 6-7:
SEC = 1000000  # 1 second = 1 million microseconds

# From add_video_track.py line 185:
duration_microseconds = int(transition_duration * 1e6)
```

The internal conversion happens automatically - **you only pass seconds to the API**.

---

## POST /add_video

Add a video track to the draft with optional trimming, placement, and effects.

### Endpoint
```
POST http://localhost:9000/add_video
Content-Type: application/json
```

### Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `draft_id` | string | ✅ Yes | - | Draft ID from `/create_draft` |
| `video_url` | string | ✅ Yes | - | Full URL to video file |
| `start` | float | No | 0 | Source video trim start (seconds) |
| `end` | float | No | auto | Source video trim end (seconds, omit for full duration) |
| `target_start` | float | No | 0 | Timeline placement position (seconds) |
| `volume` | float | No | 1.0 | Audio volume (0.0=mute, 1.0=original) |
| `speed` | float | No | 1.0 | Playback speed (0.5=slow, 2.0=fast) |
| `width` | int | No | 1080 | Draft width in pixels |
| `height` | int | No | 1920 | Draft height in pixels |
| `transition` | string | No | null | Transition effect name (see `/get_transition_types`) |
| `transition_duration` | float | No | 0.5 | Transition duration in SECONDS |
| `transform_x` | float | No | 0 | Horizontal offset |
| `transform_y` | float | No | 0 | Vertical offset |
| `scale_x` | float | No | 1 | Horizontal scale multiplier |
| `scale_y` | float | No | 1 | Vertical scale multiplier |
| `mask_type` | string | No | null | Mask type: `linear`, `mirror`, `circle`, `rectangle`, `heart`, `star` |
| `mask_center_x` | float | No | 0.5 | Mask center X (0-1 range) |
| `mask_center_y` | float | No | 0.5 | Mask center Y (0-1 range) |
| `mask_size` | float | No | 1.0 | Mask size (0-1 range) |
| `mask_rotation` | float | No | 0 | Mask rotation in degrees |
| `mask_feather` | float | No | 0 | Mask edge feathering (0-1 range) |
| `mask_invert` | bool | No | false | Invert mask |
| `background_blur` | int | No | null | Background blur (1-4: light to maximum) |

### Request Examples

**Basic Video Merger:**
```json
{
  "draft_id": "dfd_cat_1763211331_abc123",
  "video_url": "https://example.com/video1.mp4",
  "start": 0,
  "target_start": 0,
  "volume": 1.0
}
```

**Trim and Place:**
```json
{
  "draft_id": "dfd_cat_1763211331_abc123",
  "video_url": "https://example.com/video2.mp4",
  "start": 5.5,      // Start at 5.5 seconds into source video
  "end": 15.0,       // End at 15 seconds
  "target_start": 10.0,  // Place at 10 seconds on timeline
  "volume": 0.8
}
```

**With Transition:**
```json
{
  "draft_id": "dfd_cat_1763211331_abc123",
  "video_url": "https://example.com/video3.mp4",
  "target_start": 19.5,
  "transition": "Dissolve",
  "transition_duration": 1.0   // 1 second transition
}
```

**Speed Up Video:**
```json
{
  "draft_id": "dfd_cat_1763211331_abc123",
  "video_url": "https://example.com/timelapse.mp4",
  "speed": 2.0,      // 2x speed (video plays twice as fast)
  "target_start": 30.0
}
```

### Response

```json
{
  "error": "",
  "output": {
    "draft_id": "dfd_cat_1763211331_abc123",
    "draft_url": "https://www.install-ai-guider.top/draft/downloader?draft_id=..."
  },
  "success": true
}
```

### Error Response

```json
{
  "error": "Error occurred while processing video: ...",
  "output": "",
  "success": false
}
```

---

## POST /create_draft

Create a new CapCut draft project.

### Endpoint
```
POST http://localhost:9000/create_draft
Content-Type: application/json
```

### Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `width` | int | No | 1080 | Draft width in pixels |
| `height` | int | No | 1920 | Draft height in pixels |

### Request Example

```json
{
  "width": 1920,
  "height": 1080
}
```

### Response

```json
{
  "error": "",
  "output": {
    "draft_id": "dfd_cat_1763211331_abc123",
    "draft_url": "https://www.install-ai-guider.top/draft/downloader?draft_id=..."
  },
  "success": true
}
```

---

## POST /save_draft

Save the draft and start server-side processing.

### Endpoint
```
POST http://localhost:9000/save_draft
Content-Type: application/json
```

### Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `draft_id` | string | ✅ Yes | - | Draft ID to save |
| `draft_folder` | string | ✅ Yes | - | Folder name for saved draft |

### Request Example

```json
{
  "draft_id": "dfd_cat_1763211331_abc123",
  "draft_folder": "merged_video_2025-11-15"
}
```

### Response

```json
{
  "error": "",
  "output": {
    "task_id": "task_xyz789"
  },
  "success": true
}
```

---

## POST /query_draft_status

Check the processing status of a saved draft.

### Endpoint
```
POST http://localhost:9000/query_draft_status
Content-Type: application/json
```

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `task_id` | string | ✅ Yes | Task ID from `/save_draft` |

### Request Example

```json
{
  "task_id": "task_xyz789"
}
```

### Response (Processing)

```json
{
  "task_id": "task_xyz789",
  "status": "processing"
}
```

### Response (Completed)

```json
{
  "task_id": "task_xyz789",
  "status": "completed",
  "draft_url": "https://www.install-ai-guider.top/draft/downloader?draft_id=...",
  "video_url": "https://cdn.example.com/merged_video.mp4"
}
```

---

## POST /get_duration (Custom Endpoint)

**⚠️ NOT INCLUDED BY DEFAULT** - Use the provided script to add this endpoint.

Get video duration using FFprobe.

### Setup

```bash
cd ~/JsTagSphere/workflows
python3 add-get-duration-endpoint.py
# Restart CapCut server
```

### Endpoint
```
POST http://localhost:9000/get_duration
Content-Type: application/json
```

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `video_url` | string | ✅ Yes | Full URL to video file |

### Request Example

```json
{
  "video_url": "https://example.com/video.mp4"
}
```

### Response

```json
{
  "success": true,
  "output": 123.45,  // Duration in SECONDS
  "error": null
}
```

---

## GET /get_transition_types

List all available transition effects.

### Endpoint
```
GET http://localhost:9000/get_transition_types
```

### Response Example

```json
{
  "transitions": [
    "None",
    "Dissolve",
    "Fade to Black",
    "Fade to White",
    "Slide Left",
    "Slide Right",
    "Slide Up",
    "Slide Down",
    "Zoom In",
    "Zoom Out",
    ...
  ]
}
```

---

## Common Patterns

### Pattern 1: Merge Videos Sequentially

```javascript
// 1. Create draft
const draft = await post('/create_draft', { width: 1920, height: 1080 });
const draftId = draft.output.draft_id;

let timelinePosition = 0;

// 2. Add videos sequentially
for (const video of videos) {
  await post('/add_video', {
    draft_id: draftId,
    video_url: video.url,
    target_start: timelinePosition
  });
  timelinePosition += video.duration;  // Move timeline forward
}

// 3. Save draft
const saveResult = await post('/save_draft', {
  draft_id: draftId,
  draft_folder: 'merged_' + Date.now()
});

// 4. Poll for completion
let status = 'processing';
while (status === 'processing') {
  await sleep(10000);  // Wait 10 seconds
  const result = await post('/query_draft_status', {
    task_id: saveResult.output.task_id
  });
  status = result.status;
}

// 5. Download video
const videoUrl = result.video_url;
```

### Pattern 2: Trim and Merge

```javascript
// Trim first 10 seconds of video1, then add video2
await post('/add_video', {
  draft_id: draftId,
  video_url: 'https://example.com/video1.mp4',
  start: 0,
  end: 10,
  target_start: 0
});

await post('/add_video', {
  draft_id: draftId,
  video_url: 'https://example.com/video2.mp4',
  target_start: 10  // Start where video1 ends
});
```

### Pattern 3: Add Transitions

```javascript
// Get available transitions first
const transitions = await get('/get_transition_types');

// Add video with transition
await post('/add_video', {
  draft_id: draftId,
  video_url: 'https://example.com/video.mp4',
  target_start: 0,
  transition: 'Dissolve',
  transition_duration: 1.5  // 1.5 second transition
});
```

---

## Timeline Calculation

### Understanding Timeline Positions

```
Video 1: duration=10s
  source: [0 ──────── 10]
  timeline: [0 ──────── 10]
  target_start: 0

Video 2: duration=15s
  source: [0 ────────────── 15]
  timeline: [10 ────────────── 25]
  target_start: 10  (where video 1 ends)

Video 3: duration=8s
  source: [0 ──────── 8]
  timeline: [25 ──────── 33]
  target_start: 25  (where video 2 ends)
```

### With Speed Adjustment

```
Video: duration=20s, speed=2.0
  source: [0 ──────────────────── 20]
  timeline: [0 ────── 10]  (20s / 2.0 = 10s on timeline)
  target_start: 0
```

### With Trimming

```
Video: full duration=60s, start=10, end=30
  source: [10 ──────────────────── 30]  (20s segment)
  timeline: [0 ──────────────────── 20]
  target_start: 0
```

---

## Error Handling

### Common Errors

1. **Timeline Overlap**
```json
{
  "error": "New segment overlaps with existing segment [start: 0, end: 10000000].",
  "success": false
}
```
**Solution:** Ensure `target_start` values don't overlap. Each video should start where the previous one ends.

2. **Invalid Transition**
```json
{
  "error": "Unsupported transition type: fade, transition setting skipped.",
  "success": false
}
```
**Solution:** Use `/get_transition_types` to get valid transition names (e.g., "Dissolve", not "fade").

3. **Connection Refused**
```
ECONNREFUSED ::1:9000
```
**Solution:** Ensure CapCut API server is running: `python capcut_server.py`

4. **Missing draft_id**
```json
{
  "error": "draft_id is required",
  "success": false
}
```
**Solution:** Always call `/create_draft` first and use the returned `draft_id`.

---

## Best Practices

### 1. Always Validate Durations

```javascript
// Get actual duration before calculating timeline
const durationResult = await post('/get_duration', {
  video_url: videoUrl
});

if (!durationResult.success) {
  console.error('Failed to get duration:', durationResult.error);
  return;
}

const duration = durationResult.output;
```

### 2. Calculate Timeline Positions Carefully

```javascript
let position = 0;
for (const video of videos) {
  const duration = await getDuration(video.url);

  await addVideo({
    draft_id: draftId,
    video_url: video.url,
    target_start: position
  });

  position += duration;  // Move to next position
}
```

### 3. Handle Async Processing

```javascript
// Poll with exponential backoff
async function waitForCompletion(taskId) {
  let delay = 5000;  // Start with 5 seconds
  const maxDelay = 30000;  // Max 30 seconds

  while (true) {
    const result = await post('/query_draft_status', { task_id: taskId });

    if (result.status === 'completed') {
      return result;
    }

    await sleep(delay);
    delay = Math.min(delay * 1.5, maxDelay);  // Increase delay
  }
}
```

### 4. Use Proper Video Dimensions

```javascript
// 16:9 landscape
{ width: 1920, height: 1080 }

// 9:16 portrait (TikTok, Instagram Reels)
{ width: 1080, height: 1920 }

// Square (Instagram posts)
{ width: 1080, height: 1080 }

// 4K UHD
{ width: 3840, height: 2160 }
```

---

## References

- **Source Code**: https://github.com/sun-guannan/CapCutAPI
- **Server File**: `capcut_server.py` (all HTTP endpoints)
- **Video Implementation**: `add_video_track.py` (parameter details)
- **Time Utilities**: `time_util.py` (time conversion logic)
- **Duration Retrieval**: `get_duration_impl.py` (FFprobe integration)

---

**Version**: 1.0
**Last Updated**: 2025-11-15
**Compatibility**: CapCut API commit 1bb3194
