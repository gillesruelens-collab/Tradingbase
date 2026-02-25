#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"
PID_FILE=".server.pid"

if [[ ! -f "$PID_FILE" ]]; then
  echo "No PID file found. Site may already be stopped."
  exit 0
fi

PID=$(cat "$PID_FILE")
if kill -0 "$PID" 2>/dev/null; then
  kill "$PID"
  echo "Stopped SMB site (PID $PID)"
else
  echo "Process $PID not running. Cleaning stale PID file."
fi

rm -f "$PID_FILE"
