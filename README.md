# YouTube Video Metadata API

A REST API to extract basic YouTube video metadata.

## System Requirements

- [uv](https://docs.astral.sh/uv/) - Python package manager
- [Google API key](https://developers.google.com/youtube/v3/getting-started) - exposed as `YOUTUBE_API_KEY` environment variable.

## Install Dependencies

```bash
uv venv
uv sync
```

## Run the Server

Local development:

```bash
just dev
```

Production:

```bash
just up
```

## Documentation

- **OpenAPI Docs**: `http://localhost:8000/docs`
- **OpenAPI Spec**: `http://localhost:8000/openapi.json`
