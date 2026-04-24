#!/bin/bash
set -euo pipefail
PLAYER="player"; PASS="Player@123"
FLAG="HACKTIFY{ARCHIVE_EXFIL_$(hostname|sha256sum|cut -c1-8)}"
id "$PLAYER" &>/dev/null || { useradd -m -s /bin/bash "$PLAYER"; echo "$PLAYER:$PASS"|chpasswd; }
echo "$PLAYER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/player-arch; chmod 440 /etc/sudoers.d/player-arch
mkdir -p /opt/loot/{documents,databases,configs}
echo "$FLAG" > /opt/loot/documents/flag.txt
echo "mysql_root_pass=Pr0ductionDB!" > /opt/loot/configs/db.conf
echo "aws_secret_key=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY" > /opt/loot/configs/aws.conf
echo "Name,SSN,DOB" > /opt/loot/databases/employees.csv
echo "John Doe,123-45-6789,1985-03-12" >> /opt/loot/databases/employees.csv
echo "Jane Smith,987-65-4321,1990-07-22" >> /opt/loot/databases/employees.csv
chmod -R 644 /opt/loot/ && chmod -R +X /opt/loot/
cat > /home/$PLAYER/README.txt << 'RMEOF'
=== T1560.001 Archive Collected Data via Utility ===
Login  : player / Player@123
Loot dir: /opt/loot/ (documents, databases, configs)
Goal   : Stage and archive the collected data before exfiltration.
         1. Tar+gzip all loot: tar czf /tmp/loot.tar.gz /opt/loot/
         2. Password-protected zip: zip -P 'Ex!lPass' /tmp/loot.zip -r /opt/loot/
         3. 7z with AES-256: 7z a -p'Ex!lPass' -mhe=on /tmp/loot.7z /opt/loot/
         4. Encrypted tar: tar czf - /opt/loot/ | openssl enc -aes-256-cbc -k 'key' > /tmp/loot.enc
         5. Read the flag from /opt/loot/documents/flag.txt
RMEOF
chown $PLAYER:$PLAYER /home/$PLAYER/README.txt
echo "[+] T1560.001 setup complete."
