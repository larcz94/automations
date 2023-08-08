#set the log dates and path | default script removes 10 days old log files
$limit = (Get-Date).AddDays(-10)
$log_paths = ("C:\log")

function Get-DiskSpace {
    param($driveName)

    #Get Disk Space Details 
    Get-WmiObject -Class Win32_LogicalDisk | Where-Object {$_.DeviceID -eq $driveName} | Select-Object DeviceID, @{label='FreePercent (%)'; expression={[Math]::Round(($_.freespace / $_.size) * 100, 2)}}
}

Get-DiskSpace -driveName "C:"

# Delete Logs on the path
ForEach ($log_path in $log_paths){
    if (Test-Path $log_path -ErrorAction SilentlyContinue)
    {
        Get-ChildItem -Path $log_path -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $limit } | Remove-Item -Force
    }
}

#Get Disk Space Details after delete the log file
Get-DiskSpace "C:"