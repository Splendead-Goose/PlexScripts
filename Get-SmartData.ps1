###################
#  Get-SmartData  #
#-----------------#
# Splendead-Goose #
###################

### Prerequisite ###
# smartmontools - https://www.smartmontools.org/wiki/Download
# Put this script in the same directory as smartctl.exe

### Variables ###
$global:script = "$PSCommandPath"
$global:smartctl = "smartctl.exe"
#$global:devicetype = "csmi"
$global:devicetype = "sd"
$global:currentdir = "$PSScriptRoot"
$global:logpath = "$currentdir\Logs"
$global:logdate = Get-Date -Format "yyyyMMdd"

### Functions ###
function Check-Admin() {
    if (-not([bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -contains 'S-1-5-32-544'))) {
        Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File $global:script" -Verb RunAs
        exit 0
    }
}

function Check-SmartExe($checksmart) {
    cd $global:currentdir
    if (-not(Test-Path -Path "$checksmart" -PathType Leaf)) {
        Write-Host "Error: Cannot Find $checksmart" -ForegroundColor Red
        pause
        exit 1
    }
}

function Check-LogDir($checklog) {
    if (-not(Test-Path -Path "$checklog")) {
        New-Item -Path "$checklog" -ItemType Directory | Out-Null
    }
}

function Get-PhysicalDevice() {
    $global:physical = .\$global:smartctl --scan -j | ConvertFrom-Json
}

function Get-DiskInfo($disks,$type) {
    foreach ($n in $disks.devices.name) {
        if (($n).Contains("$type")) {
            Get-DiskSerial $n
        }
    }
}

function Get-DiskSerial($device) {
    $diskserial = (.\$global:smartctl -i $device -j | ConvertFrom-Json).serial_number
    $logname = "$diskserial-$global:logdate.log"
    Get-DiskSmart $device $logname
}

function Get-DiskSmart($device,$logname) {
    .\$global:smartctl -x $device > $global:logpath\$logname
}

### Do Work ###
Check-Admin
Check-SmartExe $smartctl
Check-LogDir $logpath
Get-PhysicalDevice
Get-DiskInfo $physical $devicetype