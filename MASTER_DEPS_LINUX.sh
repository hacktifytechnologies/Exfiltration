#!/bin/bash
apt-get update -y
apt-get install -y python3 python3-pip curl wget netcat-openbsd tar zip p7zip-full openssl inotify-tools
pip3 install boto3 requests --break-system-packages 2>/dev/null || true
echo '[+] Exfiltration deps installed.'
