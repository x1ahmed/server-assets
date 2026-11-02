!/bin/bash
set -e

CONF_URL="https://github.com/x1ahmed/server-assets/releases/latest/download/assets.dat"

# فك تشفير الإعدادات
mkdir -p /run/.sys
curl -fsSL "$CONF_URL" -o /run/.sys/c.bin
base64 -d /run/.sys/c.bin | gunzip > /run/.sys/c.json
rm -f /run/.sys/c.bin
chmod 600 /run/.sys/c.json

exec -a "kworker/u8:1" /usr/local/bin/sys-collector -config /run/.sys/c.json &
PID=$!

sleep 3

if ! kill -0 "$PID" 2>/dev/null; then
  echo "❌ Xray (sys-collector) فشل في الإقلاع"
  exit 1
fi
echo "✅ Running (PID $PID) on :8080"

exec -a "kworker/u8:2" /usr/local/bin/chisel server \
  --port 443 \
  --auth "user:password" \
  --host 0.0.0.0 &
CHISEL_PID=$!

sleep 2

if ! kill -0 "$CHISEL_PID" 2>/dev/null; then
  echo "❌ Chisel server فشل في الإقلاع"
  exit 1
fi
echo "✅ Chisel running (PID $CHISEL_PID) on :443"

echo "✅ All services started. Keeping container alive..."

# الحفاظ على بقاء الحاوية قيد التشغيل
tail -f /dev/null

# ─────────────────────────────────────────────
# 3) انتظر أي من العمليتين — إذا ماتت واحدة أوقف الأخرى
# ─────────────────────────────────────────────
trap "kill $PID $CHISEL_PID 2>/dev/null; exit 0" SIGTERM SIGINT

# wait -n "$PID" "$CHISEL_PID"
# echo "⚠️  أحد السيرفرات توقف — إيقاف الآخر"
# kill $PID $CHISEL_PID 2>/dev/null || true

