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

### Public URL via Tunnels

You can expose the local server publicly using either ngrok or Cloudflare Tunnel.

• ngrok

```bash
just up-ngrok
```

This starts the server and an ngrok tunnel, printing the public URL.

• Cloudflare Tunnel

Requirements:
- Install cloudflared
- Have a Cloudflare account and a zone (domain) added
- Create a Tunnel in the Cloudflare dashboard and obtain the Tunnel Token

Run:

```bash
CLOUDFLARE_TUNNEL_TOKEN=... just up-cloudflare
# Optional, if you've mapped a DNS record to the tunnel
CUSTOM_DOMAIN=api.example.com CLOUDFLARE_TUNNEL_TOKEN=... just up-cloudflare
```

Notes:
- With a custom domain (DNS mapped to your tunnel), your public URL will be https://YOUR_DOMAIN
- Without DNS, a best-effort ephemeral https://*.trycloudflare.com URL is extracted from logs and printed

Stop services:

```bash
just down
```

## API Usage

```bash
curl "http://localhost:8000/api/video-metadata?url=https://www.youtube.com/watch?v=ZHYK0m9rpB0"
```

## Documentation

- **Swagger UI**: `http://localhost:8000/docs`
- **OpenAPI Spec**: `http://localhost:8000/openapi.json`
