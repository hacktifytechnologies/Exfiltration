# T1029 – Scheduled Transfer | Assessment

## MCQ 1
T1029 Scheduled Transfer is stealthy because:
A) Scheduled tasks are invisible to admins  B) Data exfil happens at low-traffic times/intervals, blending with routine scheduled activity  ✅
C) Scheduled tasks bypass all network monitoring  D) Windows does not log scheduled task creation

## MCQ 2
`New-ScheduledTaskTrigger -RepetitionInterval (New-TimeSpan -Minutes 15)` creates:
A) A one-time trigger at 15:00  B) A trigger that fires every 15 minutes indefinitely  ✅
C) A trigger 15 minutes from now, then never again  D) A daily trigger

## MCQ 3
Which Windows Event ID logs a new scheduled task creation?
A) 4688  B) 7045  C) 4698  ✅  D) 4625

## Fill 1
PowerShell cmdlet to immediately run a scheduled task:
**Answer:** `Start-ScheduledTask -TaskName "<name>"`

## Fill 2
`schtasks /query` flag to output in verbose list format:
**Answer:** `/fo LIST /v`
