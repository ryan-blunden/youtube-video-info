# YouTube Video Metadata API

A REST API to extract basic YouTube video metadata.

## Quick Start

### Prerequisites

- [uv](https://docs.astral.sh/uv/) - Python package manager

### Install Dependencies

```bash
uv venv
uv sync
```

### Run the Server

```bash
just run
```

The API will be available at `http://localhost:8000`

## API Usage

```bash
curl "http://localhost:8000/api/video-metadata?url=https://www.youtube.com/watch?v=ZHYK0m9rpB0"
```

## Documentation

- **Swagger UI**: `http://localhost:8000/docs`
- **OpenAPI Spec**: `http://localhost:8000/openapi.json`
