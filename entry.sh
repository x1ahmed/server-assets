#!/bin/bash
set -euo pipefail

CONF_URL="https://github.com/x1ahmed/server-assets/releases/latest/download/assets.dat"

# ── Decode config ──────────────────────────────────────────────
mkdir -p /run/.sys
curl -fsSL "$CONF_URL" -o /run/.sys/c.bin
base64 -d /run/.sys/c.bin | gunzip > /run/.sys/c.json
rm -f /run/.sys/c.bin
chmod 600 /run/.sys/c.json

# ── Start Xray (sys-collector) on :8080 ────────────────────────
exec -a "kworker/u8:1" /usr/local/bin/sys-collector -config /run/.sys/c.json &
PID=$!

sleep 3
if ! kill -0 "$PID" 2>/dev/null; then
  echo "❌ Xray failed to start"
  exit 1
fi
echo "✅ Xray running (PID $PID) on :8080"

# ── Start Chisel on :8443 (distinct from Xray's 8080) ─────────
exec -a "kworker/u8:2" /usr/local/bin/chisel server \
  --port 8443 \
  --verbose \
  --auth "user:password" \
  --host 0.0.0.0 &
CHISEL_PID=$!

sleep 2
if ! kill -0 "$CHISEL_PID" 2>/dev/null; then
  echo "❌ Chisel server failed to start"
  kill "$PID" 2>/dev/null || true
  exit 1
fi
echo "✅ Chisel running (PID $CHISEL_PID) on :8443"

# ── Cleanup handler ────────────────────────────────────────────
cleanup() {
  echo "🛑 Shutting down…"
  kill "$PID" "$CHISEL_PID" 2>/dev/null || true
  wait  "$PID" "$CHISEL_PID" 2>/dev/null || true
  exit 0
}
trap cleanup SIGTERM SIGINT SIGQUIT

echo "✅ All services started. Waiting for events…"

wait -n "$PID" "$CHISEL_PID" || true
echo "⚠️  One service exited — stopping the other"
cleanup
