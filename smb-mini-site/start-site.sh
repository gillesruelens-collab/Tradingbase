#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"
PORT="${1:-8787}"
PID_FILE=".server.pid"
LOG_FILE=".server.log"

if [[ -f "$PID_FILE" ]] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
  echo "SMB site already running (PID $(cat "$PID_FILE")) on port $PORT"
  exit 0
fi

nohup python3 -m http.server "$PORT" >"$LOG_FILE" 2>&1 &
echo $! > "$PID_FILE"

IP=$(hostname -I | awk '{print $1}')
echo "SMB site started"
echo "Local:   http://localhost:$PORT"
echo "Network: http://$IP:$PORT"
echo "PID: $(cat "$PID_FILE")"
echo "Log: $LOG_FILE"
