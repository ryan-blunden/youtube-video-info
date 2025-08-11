#!/usr/bin/env bash
set -euo pipefail

# Resolve project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="${SCRIPT_DIR}/.."
cd "${ROOT_DIR}"

# Configurable params
PORT="${PORT:-8000}"
WORKERS="${WORKERS:-2}"
APP="${APP:-main:app}"
PID_FILE="${PID_FILE:-uvicorn.pid}"
LOG_FILE="${LOG_FILE:-server.log}"

# If already running, exit early
if [ -f "${PID_FILE}" ] && kill -0 "$(cat "${PID_FILE}")" 2>/dev/null; then
  echo "uvicorn already running (pid $(cat "${PID_FILE}"))"
  exit 0
fi

# Start server with Doppler-managed env, log to server.log, and write PID
# Using nohup and exec ensures proper daemonization and signal handling
nohup bash -lc "exec uv run uvicorn ${APP} --host 0.0.0.0 --port ${PORT} --workers ${WORKERS} --proxy-headers" >> "${LOG_FILE}" 2>&1 &
# Record PID of backgrounded process
echo $! > "${PID_FILE}"
echo "Started uvicorn (pid $(cat "${PID_FILE}")) on :${PORT} with workers=${WORKERS}"
