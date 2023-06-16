---
layout: post
tags: [programming, windows, cli, powershell]
excerpt_separator: "\n\n"
---

Here is a basic backup script that I made from the `powershell` exam the second grade had today.

```powershell
<#
    .SYNOPSIS
    Backup file from folder matching extension

    .DESCRIPTION
    Backup all the files from a 'WinPath' that match the given 'FileExtension'.
    The 'Backup' directory is created by default.
    You can also 'SearchBackup' in the 'Backup' directory with a regex.

    .PARAMETER WinPath
    Path to the directory to search in

    .PARAMETER FileExtension
    Extension of files to backup

    .PARAMETER Backup
    Create Backup directory (true by default)

    .PARAMETER SearchBackup
    Search pattern in backed-up files (false by default)
#>

param(
    [Parameter(mandatory=$true)]
    [string]$WinPath,

    [Parameter(mandatory=$true)]
    [string]$FileExtension,
    
    [bool]$Backup = $true,
    [string]$SearchBackup
)

# check if the directory exists
if (!(Test-Path -Path $WinPath -PathType Container)) {
    Write-Host "'$WinPath' does not exist or is not a directory"
    exit 1
}

# if SearchBackup then show files matching and quit
if ($SearchBackup -ne '') {
    if (!(Test-Path -Path "$WinPath" -PathType Container)) {
        Write-Host "'$WinPath' does not exist or is not a directory"
        exit 2
    }
    Get-ChildItem -Path "$WinPath/Backup" -File | ForEach-Object {
        if ($_.Name -match $FileExtension) {
            Write-Host "$_"
        }
    }
    exit
}

# create the Backup directory
if ($Backup) {
    $null = New-Item -Path "$WinPath/Backup" -ItemType Directory -Force
}

# add all files matching the extension to the Backup directory
$count = 0
Get-ChildItem -Path $WinPath –Recurse -File | ForEach-Object {
    if ($_.Extension -eq $FileExtension -and $_.DirectoryName -cnotmatch "Backup") {
        Move-Item -Path $_ -Destination "$WinPath/Backup"
        $count += 1
    }
}
Write-Host "$count file(s) backed-up"
```

I think it is mostly self explanatory^^