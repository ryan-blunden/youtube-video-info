#!/usr/bin/env bash

set -euo pipefail

# Usage options:
#  1) Quick tunnel (ephemeral):
#       just up-cloudflare
#     Produces a https://*.trycloudflare.com URL.
#
#  2) Named tunnel + DNS (custom domain):
#       CLOUDFLARE_TUNNEL_TOKEN=... CUSTOM_DOMAIN=api.example.com just up-cloudflare
#     Assumes the named tunnel is configured in Cloudflare to route to http://localhost:$PORT.

TUNNEL_NAME=${TUNNEL_NAME:-youtube-video-meta}
PORT=${PORT:-8000}

if ! command -v cloudflared >/dev/null 2>&1; then
  echo "❌ cloudflared is not installed. Install from https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/downloads/"
  exit 1
fi

echo "Starting Cloudflare Tunnel..."
if [ -n "${CLOUDFLARE_TUNNEL_TOKEN:-}" ]; then
  # Named tunnel using token; routing is managed by your Cloudflare config (ingress rules)
  cloudflared tunnel run --token "$CLOUDFLARE_TUNNEL_TOKEN" --logfile cloudflared.log --metrics 127.0.0.1:58887 >/dev/null 2>&1 &
  CF_PID=$!
  echo $CF_PID > .cloudflared.pid
else
  # Quick tunnel to local port
  cloudflared tunnel --url http://localhost:$PORT --logfile cloudflared.log --metrics 127.0.0.1:58887 >/dev/null 2>&1 &
  CF_PID=$!
  echo $CF_PID > .cloudflared.pid
fi

# NOTE: When using the token-based quick tunnel, the public URL is not printed locally in a stable way.
# However, for named tunnels + DNS routes, your CUSTOM_DOMAIN will route to this local service.

# Try to infer a public URL for quick tunnels (best effort):
PUBLIC_URL=""
for i in {1..10}; do
  sleep 1
  # cloudflared logs sometimes include the tunnel hostname; try to parse
  if [ -f cloudflared.log ]; then
    PUBLIC_URL=$(grep -Eo "https?://[a-zA-Z0-9.-]+\.trycloudflare\.com" cloudflared.log | tail -n1 || true)
    if [ -n "$PUBLIC_URL" ]; then
      break
    fi
  fi
  echo "Waiting for Cloudflare Tunnel URL... (attempt $i/10)"
done

if [ -n "${CUSTOM_DOMAIN:-}" ]; then
  export BASE_URL="https://$CUSTOM_DOMAIN"
elif [ -n "$PUBLIC_URL" ]; then
  export BASE_URL="$PUBLIC_URL"
fi

# Start the FastAPI server in the background
echo "Starting FastAPI server..."
uv run uvicorn main:app --host 0.0.0.0 --port "$PORT" --reload > server.log 2>&1 &
SERVER_PID=$!
echo $SERVER_PID > .server.pid
sleep 2

echo "✅ Server is running!"
echo "📱 Local URL: http://localhost:$PORT"
if [ -n "${CUSTOM_DOMAIN:-}" ]; then
  echo "🌐 Public URL (custom domain): https://$CUSTOM_DOMAIN"
fi
if [ -n "$PUBLIC_URL" ]; then
  echo "🌐 Public URL (ephemeral): $PUBLIC_URL"
fi

# Simple smoke test if we have a URL
TEST_URL="${CUSTOM_DOMAIN:+https://$CUSTOM_DOMAIN}"
if [ -z "$TEST_URL" ] && [ -n "$PUBLIC_URL" ]; then
  TEST_URL="$PUBLIC_URL"
fi

if [ -n "$TEST_URL" ]; then
  echo "\nTesting public URL..."
  if curl -s "$TEST_URL/" | grep -q "openapi"; then
    echo "✅ Cloudflare tunnel is responding!"
  else
    echo "⚠️  Cloudflare tunnel may need a moment to become fully available"
  fi
fi

echo "\nServer PID: $SERVER_PID (saved to .server.pid)"
echo "Cloudflared PID: $CF_PID (saved to .cloudflared.pid)"
echo "\nUse 'just down' to stop both services"
