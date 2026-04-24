# T1020 – Automated Exfiltration | Assessment

## MCQ 1
T1020 Automated Exfiltration differs from manual exfiltration because:
A) It is faster  B) It runs without human interaction — exfil happens automatically when trigger conditions are met  ✅
C) It uses different protocols  D) It cannot be detected

## MCQ 2
`inotifywait -m -e close_write /dir` monitors:
A) Network connections to /dir  B) Files in /dir that are closed after writing (new or modified files)  ✅
C) Process executions in /dir  D) Directory permission changes

## MCQ 3
Automated exfiltration via cron is hard to detect because:
A) cron is not logged  B) The exfil blends with regular scheduled activity and no interactive session is required  ✅
C) cron traffic is encrypted  D) Cron jobs cannot access sensitive files

## Fill 1
`inotifywait` event flag to trigger when a file is written and closed:
**Answer:** `close_write`

## Fill 2
cron schedule expression for "every 10 minutes":
**Answer:** `*/10 * * * *`
