#!/bin/bash
apt-get update -y && apt-get install -y curl python3 python3-pip
pip3 install requests --break-system-packages 2>/dev/null || true
