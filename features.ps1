#disable domain firewall
Write-Host "Disable Domain Firewall"
Set-NetFirewallProfile -Name "Domain" -Enabled False -Verbose

Write-Host "WINRMPASS: $env:WINRMPASS"

Write-Host "Starting Installation of Windows Roles and Features"
$features = @(
	"RDS-RD-Server",
	"NET-Framework-45-Core"
	#optional
	#"Remote-Assistance",
	#"Telnet-Client",
	#"RSAT-DNS-Server",
	#"RSAT-DHCP",
	#"RSAT-AD-Tools"
)

foreach ($feature in $features)
{
	Install-WindowsFeature $feature -Verbose
}
