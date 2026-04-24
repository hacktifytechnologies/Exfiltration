#!/bin/bash
apt-get update -y && apt-get install -y python3 python3-pip curl
pip3 install boto3 google-cloud-storage requests --break-system-packages 2>/dev/null || true
