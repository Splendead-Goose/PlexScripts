# PlexScripts
Collection of Scripts for Plex

**Use at your own risk - I am not responsible for anything related to using these scripts**

# Check-Plex.ps1
* Recently (around PMS 1.26.*) Plex Media Server for Windows has been crashing in a wierd way - PMS will be running, however, nothing can connect
* This script basically monitors the index.html page that PMS has - If the HTTP Response Code does not equal 200, then Plex can be considered 'Down'
* The script will automatically restart PMS when the $autoRestart variable is set to "yes" (No Longer Default)
* The auto restart will also copy the latest PMS log to the current users Downloads directory
* When $autoRestart is off, the script will stop and display a Down message
* There is also some basic logging turned on by default to the current users Downloads directory
* Default checking interval is every 5 min - all time variables are in seconds
* There is also a check to see if the current time is in the range for Scheduled Tasks - no auto restart if within range
* This script requires PowerShell 7 to be installed
* Right-click the script and click "Run with PowerShell 7"
* This is a blocking script which will remain open the entire time it is running
![Check-Plex](/Check-Plex-Screenshot.png?raw=true "Check Plex Screenshot")

# Get-SmartData.ps1
* This was built to log SMART data from local disks
* This can be run as a Scheduled Task (requires Highest Privileges) or on-demand (will UAC prompt if enabled)
* Requires smartmontools (https://www.smartmontools.com/) - smartctl.exe
* Just place the script into the same directory as smartctl.exe
* Logging happens in that same directory under "Logs"
* Each log filename is formatted as: serial-date.log
* This uses the smartctl "-x" switch instead of the legacy "-a"
* Default device type is set for: /dev/sd*