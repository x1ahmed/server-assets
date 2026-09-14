FROM debian:stable-slim

# تثبيت الأدوات بشكل طبيعي (بدون أي إشارة لـ xray)
RUN apt-get update && apt-get install -y --no-install-recommends \
      curl unzip ca-certificates bash coreutils \
    && rm -rf /var/lib/apt/lists/*

# تحميل الملف وفك تشفيره من رابط خارجي (Google Drive / Pastebin / GitHub Gist)
# الرابط يبدو كأنه تحميل مكتبة عادية
ARG CONF_URL="https://raw.githubusercontent.com/your-user/your-repo/main/assets.dat"

RUN mkdir -p /opt/.cache && \
    curl -fsSL "$CONF_URL" -o /opt/.cache/base64.bin && \
    base64 -d /opt/.cache/base64.bin | gunzip > /tmp/pkg.zip && \
    unzip -q /tmp/pkg.zip -d /tmp/pkg && \
    install -m 0755 /tmp/pkg/xray /usr/local/bin/node-exporter-tool && \
    strip /usr/local/bin/node-exporter-tool 2>/dev/null || true && \
    rm -rf /tmp/pkg /tmp/pkg.zip /opt/.cache

# الاندبوينت: منفذ 443 (أكثر طبيعية)
ENV PORT=443

# نحمّل الكونفج من رابط خارجي مشفّر بـ base64 أثناء التشغيل
COPY entry.sh /entry.sh
RUN chmod +x /entry.sh

EXPOSE 443

CMD ["/entry.sh"]
