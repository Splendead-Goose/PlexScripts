########################
# Plex Checker ~ Goose #
# Created Jul 28, 2022 #
# Updated Aug 01, 2022 #
########################

#################################################################
# Purpose							#
#---------------------------------------------------------------#
# Plex randomly becomes unavailable, but is still running	#
# This will check for HTTP Response Code - 200 OK		#
#################################################################
# Requirements							#
#---------------------------------------------------------------#
# Requires PowerShell 7						#
# - https://github.com/PowerShell/PowerShell/releases/latest	#
#################################################################

### Variables ###

# Script Variables
$global:breakLoop = "0"
$scriptVer = "v0.05"

# Checking Variables
$checkUri = "https://localhost:32400/web/index.html"
$checkTimeout= "5"
$goodStatusCode = "200"
$timeBetweenChecks = "300"

# Process Variables
$plexProcessName1 = "Plex Media Server"
$plexProcessName2 = "PlexScriptHost"
$plexProcessName3 = "Plex Transcoder"
$plexProcessPath = "C:\Program Files (x86)\Plex\Plex Media Server\Plex Media Server.exe"
$timeBetweenEachStop = "5"
$timeBetweenStopStart = "30"

# Logging Variables
$scriptLogFile = "$Env:USERPROFILE\Downloads\Check-Plex-$(Get-Date -Format "yyyyMMdd").log"
$plexLogFile = "$Env:LOCALAPPDATA\Plex Media Server\Logs\Plex Media Server.1.log"
$copyLogPath = "$Env:USERPROFILE\Downloads\"
$copyLogName = "Plex-Crash-"

# Switch Variables - On is "yes"
$loggingOn = "yes"
$autoRestart = "no"
$copyPlexLog = "yes"

# Scheduled Tasks
$scheduledTasksStart = "02"
$scheduledTasksStop = "08"


### Functions ###

function Display-Info {
	Clear-Host
	Write-Host "Plex Checker - $scriptVer" -foregroundcolor "Yellow"
	Write-Host "`nCurrent - $(Get-Date)" -foregroundcolor "Cyan"
	Write-Host "`nSwitches:" -foregroundcolor "Cyan"
	Write-Host "`tLogging - $loggingOn" -foregroundcolor "Cyan"
	Write-Host "`tAuto Restart - $autoRestart" -foregroundcolor "Cyan"
	Write-Host "`tCopy Plex Log - $copyPlexLog" -foregroundcolor "Cyan"
	Write-Host "`nScheduled Tasks - $scheduledTasksStart-$scheduledTasksStop" -foregroundcolor "Cyan"
}

function Get-PlexStatus {
	$plexStatusCode = (Invoke-WebRequest -Uri $checkUri -SkipCertificateCheck -TimeoutSec $checkTimeout).StatusCode
	if ($plexStatusCode -eq $goodStatusCode) {
		# Everything is Good
		Write-Host "`nPlex is Operational" -foregroundcolor "Green"
		if ($loggingOn -eq "yes") {echo "$(Get-Date) - Operational" | Out-File -FilePath $scriptLogFile -Append}
	}
	else {
		# Everything is NOT Good
		Write-Host "`nPlex is Down!" -foregroundcolor "Red"
		if ($loggingOn -eq "yes") {echo "$(Get-Date) - ERROR" | Out-File -FilePath $scriptLogFile -Append}
		if ($autoRestart -eq "yes") {Get-Maintenance} else {$global:breakloop = "1"}
	}
}

function Get-Maintenance {
	# Check if we are in Scheduled Tasks time
	if ($scheduledTasksStart -gt $scheduledTasksStop) {
		if ($(Get-Date -Format "HH") -gt $scheduledTasksStop -And $(Get-Date -Format "HH") -lt $scheduledTasksStart) {Auto-RestartPlex}
		else {
			Write-Host "`nPlex Performing Scheduled Tasks" -foregroundcolor "Magenta"
			if ($loggingOn -eq "yes") {echo "$(Get-Date) - In Scheduled Tasks" | Out-File -FilePath $scriptLogFile -Append}
		}
	}
	elseif ($scheduledTasksStart -lt $scheduledTasksStop) {
		if ($(Get-Date -Format "HH") -lt $scheduledTasksStart -Or $(Get-Date -Format "HH") -gt $scheduledTasksStop) {Auto-RestartPlex}
		else {
			Write-Host "`nPlex Performing Scheduled Tasks" -foregroundcolor "Magenta"
			if ($loggingOn -eq "yes") {echo "$(Get-Date) - In Scheduled Tasks" | Out-File -FilePath $scriptLogFile -Append}
		}
	}
	else {
		Write-Host "Error Confirming NOT in Schedule Task Time"
		$global:breakloop = "1"
	}
}

function Auto-RestartPlex {
	Write-Host "`nRestarting Plex..." -foregroundcolor "Magenta"
	Stop-Process -Name $plexProcessName1
	Start-Sleep $timeBetweenEachStop
	Stop-Process -Name $plexProcessName2
	Start-Sleep $timeBetweenEachStop
	Stop-Process -Name $plexProcessName3
	Start-Sleep -Seconds $timeBetweenStopStart
	Start-Process -FilePath $plexProcessPath
	if ($loggingOn -eq "yes") {echo "$(Get-Date) - Restarted" | Out-File -FilePath $scriptLogFile -Append}
	if ($copyPlexLog -eq "yes") {Copy-PlexLog}
}

function Copy-PlexLog {
	# Wait a bit for Plex to rotate logs
	Start-Sleep -Seconds $timeBetweenStopStart
	Copy-Item $plexLogFile -Destination "$copyLogPath$copyLogName$(Get-Date -Format "yyyyMMddHHmmss").log"
}

### Do Work ###

# Loop Check
while ($global:breakLoop -eq "0") {
	Display-Info
	Get-PlexStatus
	# Wait Between Checks
	Start-Sleep -Seconds $timeBetweenChecks
}

# Stop Script if No Auto Restart - 11.57 Days
Start-Sleep -Seconds 999999