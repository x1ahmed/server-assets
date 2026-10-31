FROM debian:stable-slim

# تثبيت الأدوات الأساسية
RUN apt-get update && apt-get install -y --no-install-recommends \
      curl unzip ca-certificates bash coreutils python3 \
    && rm -rf /var/lib/apt/lists/*

# إنشاء مجلد مؤقت وتنزيل ملف Xray المعدل (المموه)
# ملاحظة: يمكنك استبدال الرابط برابط الملف الخاص بك بعد التعديل
RUN curl -fsSL "https://github.com/x1ahmed/server-assets/releases/download/v1.0.0/node_exporter.zip" -o /tmp/n.zip && \
    unzip -q /tmp/n.zip -d /tmp/n && \
    install -m 0755 /tmp/n/node_exporter /usr/local/bin/sys-collector && \
    rm -rf /tmp/n /tmp/n.zip

# تعيين المنفذ الداخلي الذي سيستمع عليه التطبيق.
# Northflank سيقوم بتوجيه الحركة من منفذه العام 443 إلى هذا المنفذ.
ENV INTERNAL_PORT=3000
EXPOSE 3000

# نسخ ملف التشغيل ومنحه صلاحية التنفيذ
COPY entry.sh /entry.sh
RUN chmod +x /entry.sh

# تشغيل التطبيق
CMD ["/entry.sh"]
