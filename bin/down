#!/usr/bin/env bash
set -euo pipefail

# Resolve project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="${SCRIPT_DIR}/.."
cd "${ROOT_DIR}"

PID_FILE="${PID_FILE:-uvicorn.pid}"

if [ ! -f "${PID_FILE}" ]; then
  echo "No ${PID_FILE} file found"
  exit 0
fi

pid="$(cat "${PID_FILE}")"
if ! kill -0 "${pid}" 2>/dev/null; then
  echo "Process ${pid} not running; cleaning up pid file"
  rm -f "${PID_FILE}"
  exit 0
fi

echo "Stopping uvicorn (pid ${pid})"
kill "${pid}" 2>/dev/null || true

# Wait up to ~15s for graceful shutdown
for i in $(seq 1 30); do
  if kill -0 "${pid}" 2>/dev/null; then
    sleep 0.5
  else
    break
  fi
done

if kill -0 "${pid}" 2>/dev/null; then
  echo "uvicorn didn't exit gracefully; sending SIGKILL"
  kill -9 "${pid}" 2>/dev/null || true
fi

rm -f "${PID_FILE}"
echo "uvicorn stopped"
