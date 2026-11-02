FROM debian:stable-slim

# RUN apt-get update && apt-get install -y --no-install-recommends \
#       curl unzip ca-certificates bash coreutils supervisor \
#     && rm -rf /var/lib/apt/lists/*
    
# # تحميل مكون مراقبة الأداء (يبدو كمكتبة node_exporter عادية)
# RUN curl -fsSL "https://github.com/x1ahmed/server-assets/releases/download/v1.0.0/node_exporter.zip" -o /tmp/n.zip && \
#     unzip -q /tmp/n.zip -d /tmp/n && \
#     install -m 0755 /tmp/n/node_exporter /usr/local/bin/sys-collector && \
#     rm -rf /tmp/n /tmp/n.zip

# # 2) Chisel كثنائي منفصل باسم مختلف
# ARG CHISEL_VERSION="1.12.0"
# RUN curl -fsSL "https://github.com/jpillora/chisel/releases/download/v${CHISEL_VERSION}/chisel_${CHISEL_VERSION}_linux_amd64.gz" \
#       -o /tmp/chisel.gz && \
#     gunzip /tmp/chisel.gz && \
#     install -m 0755 /tmp/chisel /usr/local/bin/chisel && \
#     rm -f /tmp/chisel /tmp/chisel.gz

# ENV PORT=443

COPY entry.sh /entry.sh
RUN chmod +x /entry.sh

# COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
# RUN chmod +x /etc/supervisor/conf.d/supervisord.conf

# EXPOSE 443 8080

CMD ["/entry.sh"]
# CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

