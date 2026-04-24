#Requires -RunAsAdministrator
$PlayerUsr = "player"; $PlayerPwd = ConvertTo-SecureString "Player@123!" -AsPlainText -Force
$FlagPath  = "C:\Windows\System32\flag_T1052_001.txt"
$Flag      = "HACKTIFY{USB_PHYSICAL_EXFIL_$($env:COMPUTERNAME)}"
if (-not (Get-LocalUser $PlayerUsr -EA SilentlyContinue)) {
    New-LocalUser $PlayerUsr -Password $PlayerPwd -FullName "Player" -PasswordNeverExpires
    Add-LocalGroupMember -Group "Administrators" -Member $PlayerUsr }
$SensDir = "C:\ProgramData\sensitive_docs"
New-Item -ItemType Directory -Path $SensDir -Force | Out-Null
Set-Content "$SensDir\financial_report.txt" $Flag
Add-Content "$SensDir\financial_report.txt" "Q4 Revenue: $12.5M"
Add-Content "$SensDir\financial_report.txt" "Acquisition target: TechCorp Inc."
Set-Content "$SensDir\employee_pii.csv" "Name,Email,Salary"
Add-Content "$SensDir\employee_pii.csv" "John Doe,john@corp.com,95000"
# Simulate USB drive (use a local folder as "USB")
$UsbSim = "C:\SimulatedUSB_Drive"
New-Item -ItemType Directory -Path $UsbSim -Force | Out-Null
Set-Content $FlagPath $Flag
$acl = Get-Acl $FlagPath; $acl.SetAccessRuleProtection($true,$false)
$acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("Administrators","FullControl","Allow")))
Set-Acl $FlagPath $acl
Set-Content "C:\Users\Public\Desktop\README.txt" @"
=== T1052.001 Exfiltration over USB / Physical Medium ===
Login   : $PlayerUsr / Player@123!
Sensitive data: C:\ProgramData\sensitive_docs\
Simulated USB : C:\SimulatedUSB_Drive\
Goal    : Copy sensitive data to the "USB drive" using multiple methods.
          1. xcopy: xcopy C:\ProgramData\sensitive_docs\* C:\SimulatedUSB_Drive\ /E /H /C
          2. robocopy: robocopy C:\ProgramData\sensitive_docs C:\SimulatedUSB_Drive /E /COPYALL
          3. PowerShell: Copy-Item C:\ProgramData\sensitive_docs -Dest C:\SimulatedUSB_Drive -Recurse
          4. Read the flag from: $FlagPath
"@
Write-Host "[+] T1052.001 setup complete."
