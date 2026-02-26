#!/usr/bin/env python3
"""
Placeholder update script.

Replace this with your real data/backtest pipeline.
Anything written into smb-mini-site/data/ and committed by the workflow
will trigger a new Cloudflare Pages deployment automatically.
"""
from pathlib import Path
from datetime import datetime, timezone
import json

out = Path("smb-mini-site/data")
out.mkdir(parents=True, exist_ok=True)

heartbeat = {
    "updated_at_utc": datetime.now(timezone.utc).isoformat(),
    "note": "Replace scripts/update_data.py with your real pipeline"
}

(out / "heartbeat.json").write_text(json.dumps(heartbeat, indent=2), encoding="utf-8")
print("Wrote", out / "heartbeat.json")
