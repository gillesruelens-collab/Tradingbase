#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"
PID_FILE=".server.pid"
PORT="${1:-8787}"
IP=$(hostname -I | awk '{print $1}')

if [[ -f "$PID_FILE" ]] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
  echo "RUNNING (PID $(cat "$PID_FILE"))"
  echo "Local:   http://localhost:$PORT"
  echo "Network: http://$IP:$PORT"
else
  echo "STOPPED"
fi
