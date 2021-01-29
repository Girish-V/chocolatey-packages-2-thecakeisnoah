﻿$ErrorActionPreference = 'Stop'
$toolsDir              = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$url32                 = 'https://download.anydesk.com/AnyDesk.msi'
$checksum32            = 'd3836d6abeb34fb4a98da71d4bf2f7d8d9d0fae2436f4ff0908f338f4ddeca65'

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  fileType      = 'MSI'
  softwareName  = 'AnyDesk MSI'
  validExitCodes= @(0, 3010, 1641)
}

$packageArgsInst = @{
  url           = $url32 
  checksum      = $checksum32
  checksumType  = 'sha256'
  silentArgs    = "/qn /norestart /l*v `"$($env:TEMP)\$($packageName).$($env:chocolateyPackageVersion).MsiInstall.log`""
}

Write-Host -ForegroundColor green "Trying to uninstall older versions of $packageName due to a limitation in the installer"
[array]$key = Get-UninstallRegistryKey -SoftwareName $packageArgs['softwareName']
if ($key.Count -eq 1) {
  $key | % {
    $packageArgsUninst = @{
        silentArgs = "$($_.PSChildName) /qn /norestart /l*v `"$($env:TEMP)\$($packageName).$($env:chocolateyPackageVersion).MsiUninstall.log`""
        file = ''
    }
    Uninstall-ChocolateyPackage @packageArgs @packageArgsUninst
  }
} elseif ($key.Count -eq 0) {
  Write-Host -ForegroundColor green "$packageName is not installed, continuing on to install"
} elseif ($key.Count -gt 1) {
  Write-Warning "$($key.Count) matches found!"
  Write-Warning "To prevent accidental data loss, no programs will be uninstalled."
  Write-Warning "Please alert package maintainer the following keys were matched:"
  $key | % {Write-Warning "- $($_.DisplayName)"}
}

 Install-ChocolateyPackage @packageArgs @packageArgsInst