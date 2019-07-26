$filename = $env:vda
$UnattendedArgs = "/quiet /optimize /components vda /controllers '$env:vdacontrollers' /enable_remote_assistance /enable_hdx_ports /enable_real_time_transport /virtualmachine /noreboot /noresume /logpath 'C:\Windows\Temp\VDA' /masterimage"
$filepath = "$($env:SystemRoot)\temp"

if (Test-Path ("C:\ProgramData\Citrix\XenDesktopSetup\XenDesktopVdaSetup.exe"))
{
	Write-Host "File already exists. Resuming install"
	$exit = (Start-Process ("C:\ProgramData\Citrix\XenDesktopSetup\XenDesktopVdaSetup.exe") -Wait -Verbose -Passthru).ExitCode
}
else
{
	#Write-Host "Downloading $filename"
	#Invoke-WebRequest -Uri ($url + $filename) -OutFile "$filepath\$filename" -Verbose -UseBasicParsing
	Write-Host "Installing VDA..."
	$exit = (Start-Process ("$filepath\$filename") $UnattendedArgs -Wait -Verbose -Passthru).ExitCode
}

if ($exit -eq 0)
{
	Write-Host "VDA INSTALL COMPLETED!"
}
elseif ($exit -eq 3)
{
	Write-Host "REBOOT NEEDED!"
}
elseif ($exit -eq 1)
{
	#dump log
	Get-Content "C:\Windows\Temp\VDA\Citrix\XenDesktop Installer\XenDesktop Installation.log"
	throw "Install FAILED! Check Log"
}
