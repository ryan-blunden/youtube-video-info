#!/usr/bin/env bash

echo "Stopping services..."

# Kill server process
if [ -f .server.pid ]; then
  SERVER_PID=$(cat .server.pid)
  if kill -0 "$SERVER_PID" 2>/dev/null; then
    kill "$SERVER_PID"
    echo "✅ FastAPI server stopped (PID: $SERVER_PID)"
  else
    echo "⚠️  Server process not found or already stopped"
  fi
  rm -f .server.pid
else
  echo "⚠️  No server PID file found"
fi

# Kill ngrok process
if [ -f .ngrok.pid ]; then
  NGROK_PID=$(cat .ngrok.pid)
  if kill -0 "$NGROK_PID" 2>/dev/null; then
    kill "$NGROK_PID"
    echo "✅ Ngrok stopped (PID: $NGROK_PID)"
  else
    echo "⚠️  Ngrok process not found or already stopped"
  fi
  rm -f .ngrok.pid
else
  echo "⚠️  No ngrok PID file found"
fi

# Kill cloudflared process
if [ -f .cloudflared.pid ]; then
  CF_PID=$(cat .cloudflared.pid)
  if kill -0 "$CF_PID" 2>/dev/null; then
    kill "$CF_PID"
    echo "✅ Cloudflared stopped (PID: $CF_PID)"
  else
    echo "⚠️  Cloudflared process not found or already stopped"
  fi
  rm -f .cloudflared.pid
else
  echo "⚠️  No cloudflared PID file found"
fi

# Clean up log files
rm -f server.log ngrok.log cloudflared.log

echo "🔄 All services stopped and cleaned up"
