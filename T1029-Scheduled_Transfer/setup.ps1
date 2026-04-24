#Requires -RunAsAdministrator
$PlayerUsr = "player"; $PlayerPwd = ConvertTo-SecureString "Player@123!" -AsPlainText -Force
$FlagPath  = "C:\Windows\System32\flag_T1029.txt"
$Flag      = "HACKTIFY{SCHEDULED_TRANSFER_$($env:COMPUTERNAME)}"
if (-not (Get-LocalUser $PlayerUsr -EA SilentlyContinue)) {
    New-LocalUser $PlayerUsr -Password $PlayerPwd -FullName "Player" -PasswordNeverExpires
    Add-LocalGroupMember -Group "Administrators" -Member $PlayerUsr }
$SensDir = "C:\ProgramData\sensitive"
New-Item -ItemType Directory -Path $SensDir -Force | Out-Null
Set-Content "$SensDir\data.txt" $Flag
Add-Content "$SensDir\data.txt" "employee_records=5000"
Add-Content "$SensDir\data.txt" "revenue_Q4=2.5M"
# Create the scheduled exfil task (writes to accessible output file — simulates sending to C2)
$Action  = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NonInteractive -Command `"Get-Content 'C:\ProgramData\sensitive\data.txt' | Out-File -Append 'C:\Users\Public\scheduled_exfil.txt'`""
$Trigger = New-ScheduledTaskTrigger -RepetitionInterval (New-TimeSpan -Minutes 5) -Once -At (Get-Date)
Register-ScheduledTask -TaskName "WindowsDataSync" -Action $Action -Trigger $Trigger -RunLevel Highest -EA SilentlyContinue
Set-Content $FlagPath $Flag
$acl = Get-Acl $FlagPath; $acl.SetAccessRuleProtection($true,$false)
$acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("Administrators","FullControl","Allow")))
Set-Acl $FlagPath $acl
Set-Content "C:\Users\Public\Desktop\README.txt" @"
=== T1029 Scheduled Transfer ===
Login   : $PlayerUsr / Player@123!
Goal    : A scheduled task "WindowsDataSync" is exfiltrating data every 5 minutes.
          1. Find the task: Get-ScheduledTask -TaskName "*Sync*"
          2. Examine what it does: Export-ScheduledTask -TaskName "WindowsDataSync"
          3. Run it manually: Start-ScheduledTask "WindowsDataSync"
          4. Check output: Get-Content C:\Users\Public\scheduled_exfil.txt
          5. Create your own scheduled exfil task
"@
Write-Host "[+] T1029 setup complete."
