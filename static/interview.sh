#!/bin/sh


echo "[+] Installing required software.."
apk update
apk add python3

echo "[+] Generating logs..."
awk 'BEGIN {
  for (i = 1; i <= 250; i++) {
    print "2026-10-15T09:12:01 host=office-srv src_ip=192.168.10.45 port=52341 status=SUCCESS user=alice";
    print "2026-10-15T09:12:05 host=office-srv src_ip=203.0.113.195 port=41233 status=FAILED user=root";
    print "2026-10-15T09:12:06 host=office-srv src_ip=203.0.113.195 port=41234 status=FAILED user=admin";
    print "2026-10-15T09:12:08 host=office-srv src_ip=192.168.10.82 port=55112 status=SUCCESS user=bob";
    print "2026-10-15T09:12:15 host=office-srv src_ip=198.51.100.22 port=38192 status=FAILED user=test";
    print "2026-10-15T09:12:18 host=office-srv src_ip=203.0.113.195 port=41236 status=FAILED user=root";
  }
}' > /var/log/auth_audit.log

echo "[+] Starting malicious service"
nohup python3 -m http.server 444 >/tmp/http.log 2>&1 &

echo "[+] Creating bad script"
mkdir -p /opt/scripts
cat << 'SCRIPT' > /opt/scripts/deploy.sh
#!/bin/sh
TARGET=$1
echo "Deploying maintenance update to $TARGET..."
SCRIPT
chmod 777 /opt/scripts/deploy.sh

echo "=========================================="
echo " Environment initialized. Ready for triage."
echo "=========================================="
