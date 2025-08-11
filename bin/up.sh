#!/usr/bin/env bash

# Start the FastAPI server in the background
echo "Starting FastAPI server..."
uv run uvicorn main:app --host 0.0.0.0 --port 8000 --reload > server.log 2>&1 &
SERVER_PID=$!
echo $SERVER_PID > .server.pid

# Wait a moment for server to start
sleep 3

# Start ngrok in the background
echo "Starting ngrok tunnel..."
ngrok http 8000 --log=stdout > ngrok.log 2>&1 &
NGROK_PID=$!
echo $NGROK_PID > .ngrok.pid

# Wait for ngrok to establish tunnel and retry getting URL
echo "Getting ngrok URL..."
for i in {1..10}; do
  sleep 2
  NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | jq -r '.tunnels[0].public_url' 2>/dev/null)
  if [ "$NGROK_URL" != "null" ] && [ "$NGROK_URL" != "" ] && [ "$NGROK_URL" != "null" ]; then
    break
  fi
  echo "Waiting for ngrok tunnel... (attempt $i/10)"
done

if [ "$NGROK_URL" != "null" ] && [ "$NGROK_URL" != "" ]; then
  echo "✅ Server is running!"
  echo "📱 Local URL: http://localhost:8000"
  echo "🌐 Public URL: $NGROK_URL"
  echo ""
  echo "Testing ngrok URL..."
  # Test the ngrok URL with proper headers
  if curl -s "$NGROK_URL/" -H "ngrok-skip-browser-warning: true" | grep -q "openapi"; then
    echo "✅ Ngrok tunnel is working properly!"
  else
    echo "⚠️  Ngrok tunnel may need a moment to become fully available"
  fi
  echo ""
  echo "Server PID: $SERVER_PID (saved to .server.pid)"
  echo "Ngrok PID: $NGROK_PID (saved to .ngrok.pid)"
  echo ""
  echo "💡 Note: Add header 'ngrok-skip-browser-warning: true' when testing with curl"
  echo "Use 'just down' to stop both services"
else
  echo "❌ Failed to get ngrok URL. Check if ngrok is installed and running."
  echo "You can still access the app locally at http://localhost:8000"
fi
