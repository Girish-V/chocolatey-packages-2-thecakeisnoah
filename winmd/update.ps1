﻿Import-Module AU

function global:au_SearchReplace {
    @{
        "tools\chocolateyinstall.ps1" = @{
		}
	}
}

function global:au_BeforeUpdate() {
	Get-RemoteFiles -Purge -NoSuffix 
}


function global:au_GetLatest {
	$download_page = Invoke-WebRequest -Uri https://github.com/maharmstone/winmd/releases -UseBasicParsing
	
	$url        = $download_page.links | ? href -match '.zip$'| % href | select -First 1
	$version    = ($url -split '[/]' | select -Last 1 -Skip 1).substring(1)
	$modurl     = 'https://github.com' + $url 

	return @{ Version = $version; URL32 = $modurl; PackageName = 'winmd'}
}

Update-Package -ChecksumFor none