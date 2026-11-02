#!/bin/bash
set -e

# رابط ملف الإعدادات المضغوط والمشفر
CONF_URL="https://github.com/x1ahmed/server-assets/releases/latest/download/assets.dat"

# إنشاء مجلد مؤقت لفك التشفير
mkdir -p /run/.sys
curl -fsSL "$CONF_URL" -o /run/.sys/c.bin

# فك التشفير (base64) وفك الضغط (gzip) للحصول على ملف JSON
base64 -d /run/.sys/c.bin | gunzip > /run/.sys/c.json
rm -f /run/.sys/c.bin
chmod 600 /run/.sys/c.json

# تشغيل Xray (sys-collector) في الخلفية
# نستخدم exec -a لتعيين اسم العملية، و & لتشغيلها في الخلفية
exec -a "kworker/u8:1" /usr/local/bin/sys-collector -config /run/.sys/c.json

exec -a "kworker/u8:1" /usr/local/bin/sys-collector server \
  --port 443 \
  --auth "user:password" \
  --host 0.0.0.0

echo "Try it!"

wait
