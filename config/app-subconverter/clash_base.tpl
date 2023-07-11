port: {{ default(global.clash.http_port, "7890") }}
socks-port: {{ default(global.clash.socks_port, "7891") }}
mixed-port: {{ default(global.clash.mix_port, "7892") }}
allow-lan: {{ default(global.clash.allow_lan, "true") }}
mode: Rule
log-level: {{ default(global.clash.log_level, "info") }}
external-controller: {{ default(global.clash.web_port, ":9090") }}
external-ui: dashboard
secret: {{ default(global.clash.passwd, "0000") }}


{% if default(request.clash.dns, "") == "1" %}
dns:
  enable: true
  listen: :2053
  enhanced-mode: fake-ip
  fake-ip-range: 198.18.0.1/16
  default-nameserver:
    - 8.8.8.8
  nameserver:
    - 127.0.0.1:53 # default value
    - https://doh.opendns.com/dns-query # DNS over TLS
    - https://i.233py.com/dns-query # DNS over HTTPS
{% endif %}

