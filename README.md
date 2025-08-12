# YouTube Video Metadata API

A lightweight API that retrieves essential metadata for YouTube videos using the YouTube Data API.

## Requirements

- [uv](https://docs.astral.sh/uv/) (Python packaging/runtime)
- [just](https://just.systems/man/en/) (optional, for the provided recipes)

## Configuration

Set the following environment variables before running:

- `YOUTUBE_API_KEY` (required). Create one via the [YouTube Data API](https://developers.google.com/youtube/v3/getting-started).
- `BASE_URL` (required). The public base URL of this service (e.g., `http://localhost:8000`).

## Quickstart

```bash
# 1) Install dependencies
uv venv
uv sync --no-dev

# Optional - Install dev dependencies
uv sync

# 2) Configure environment
export YOUTUBE_API_KEY=your_api_key_here
export BASE_URL=http://localhost:8000

# 3) Start the server

# Dev
just dev

# Production
just up
```

## Usage

- Endpoint: `GET /api/video-metadata`
- Query params: `url` (required) — the YouTube video URL

Example:

```bash
curl -s 'http://localhost:8000/api/video-metadata?url=https%3A%2F%2Fwww.youtube.com%2Fwatch%3Fv%3DZHYK0m9rpB0' | jq
```

Response shape:

```json
{
	"id": "ZHYK0m9rpB0",
	"title": "...",
	"description": "...",
	"thumbnail_url": "https://i.ytimg.com/...",
	"channel": "...",
	"channel_url": "https://www.youtube.com/channel/...",
	"view_count": 12345
}
```

Errors:
- `400` if `url` is missing/invalid
- `404` if the video isn’t found
- `500` if `YOUTUBE_API_KEY` is not set

## API Docs

- OpenAPI Docs: http://localhost:8000/docs
- OpenAPI Spec: http://localhost:8000/openapi.json

## Notes

- Dev deps install by default with `uv sync`. Use `uv sync --no-dev` or set `UV_NO_DEV=1` to exclude them.
- `BASE_URL` should match how clients reach the service (e.g., `http://localhost:8000`) so the OpenAPI server URL is correct.
