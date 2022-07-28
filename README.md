# PlexScripts
Collection of Scripts for Plex

**Use at your own risk - I am not responsible for anything related to using these scripts**

# Check-Plex.ps1
* Recently (around PMS 1.26.*) Plex Media Server for Windows has been crashing in a wierd way. PMS will be running, however, nothing can connect.
* This script basically monitors the index.html page that PMS has. If the HTTP Response Code does not equal 200, then Plex can be considered 'Down'.
* The script can automatically restart PMS (NOT TESTED YET) by setting the $autoRestart variable to "yes". This will also copy the latest PMS log to the current users Downloads directory.
* Default behavior when $autoRestart is off is to stop the script and display a Down message.
* There is also some basic logging turned on by default to the current users Downloads directory.
