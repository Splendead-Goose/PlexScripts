########################
# Plex Checker ~ Goose #
# Created Jul 28, 2022 #
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
$scriptVer = "v0.02"

# Checking Variables
$checkUri = "https://localhost:32400/web/index.html"
$checkTimeout= "5"
$goodStatusCode = "200"
$timeBetweenChecks = "300"

# Process Variables
$plexProcessName = "Plex Media Server"
$plexProcessPath = "C:\Program Files (x86)\Plex\Plex Media Server\Plex Media Server.exe"
$timeBetweenStopStart = "30"

# Logging Variables
$scriptLogFile = "$Env:USERPROFILE\Downloads\Check-Plex-$(Get-Date -Format "yyyyMMdd").log"
$plexLogFile = "$Env:LOCALAPPDATA\Plex Media Server\Logs\Plex Media Server.1.log"
$copyLogPath = "$Env:USERPROFILE\Downloads\Plex-Borked-$(Get-Date -Format "yyyyMMddHHmmss").log"

# Switch Variables - On is "yes"
$loggingOn = "yes"
$autoRestart = "yes"


### Functions ###

function Display-Info {
	Clear-Host
	Write-Host "Plex Checker - $scriptVer" -foregroundcolor "Yellow"
	Write-Host "`nCurrent - $(Get-Date)" -foregroundcolor "Cyan"
}

function Get-PlexStatus {
	$plexStatusCode = (Invoke-WebRequest -Uri $checkUri -SkipCertificateCheck -TimeoutSec $checkTimeout).StatusCode
	if ($plexStatusCode -eq $goodStatusCode) {
		# Everything is Good
		Write-Host "`nPlex is Operational" -foregroundcolor "Green"
		if ($loggingOn -eq "yes") {echo "$(Get-Date) - Operational" | Out-File -FilePath $scriptLogFile -Append}
	}else {
		# Everything is NOT Good
		Write-Host "`nPlex is Down!" -foregroundcolor "Red"
		if ($loggingOn -eq "yes") {echo "$(Get-Date) - ERROR" | Out-File -FilePath $scriptLogFile -Append}
		if ($autoRestart -eq "yes") {Auto-RestartPlex} else {$global:breakloop = "1"}
	}
}

function Auto-RestartPlex {
	Write-Host "`nRestarting Plex..." -foregroundcolor "Magenta"
	Stop-Process -Name $plexProcessName
	Start-Sleep -Seconds $timeBetweenStopStart
	Start-Process -FilePath $plexProcessPath
	if ($loggingOn -eq "yes") {echo "$(Get-Date) - Restarted" | Out-File -FilePath $scriptLogFile -Append}
	Copy-PlexLog
}

function Copy-PlexLog {
	# Wait a bit for Plex to rotate logs
	Start-Sleep -Seconds $timeBetweenStopStart
	Copy-Item $plexLogFile -Destination $copyLogPath
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