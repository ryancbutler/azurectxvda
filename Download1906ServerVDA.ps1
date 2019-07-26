#Downloads Citrix CVAD 1906 Server VDA
#Can be used as part of a pipeline or MDT task sequence.
#Ryan Butler TechDrabble.com @ryan_c_butler 07/19/2019

#Uncomment to use plain text or env variables
$CitrixUserName = $env:citrixusername
$CitrixPassword = $env:citrixpassword

Write-Host $CitrixUserName
#Uncomment to use credential object
#$creds = get-credential
#$CitrixUserName = $creds.UserName
#$CitrixPassword = $creds.GetNetworkCredential().Password

$downloadpath = "$($env:SystemRoot)\temp\$($env:vda)"
Write-Host $downloadpath

$code = @"
public class SSLHandler
{
    public static System.Net.Security.RemoteCertificateValidationCallback GetSSLHandler()
    {
        return new System.Net.Security.RemoteCertificateValidationCallback((sender, certificate, chain, policyErrors) => { return true; });
    }
}
"@
#compile the class
try {
	if ([SSLHandler])
	{
		Write-Verbose "SSLHandler already loaded"
	}
}
catch
{
	Write-Verbose "SSLHandler loading"
	Add-Type -TypeDefinition $code
}


[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = [SSLHandler]::GetSSLHandler()

#Initialize Session 
Invoke-WebRequest "https://identity.citrix.com/Utility/STS/Sign-In?ReturnUrl=%2fUtility%2fSTS%2fsaml20%2fpost-binding-response" -SessionVariable websession -Verbose -UseBasicParsing

#Set Form
$form = @{
	"persistent" = "on"
	"userName" = $CitrixUserName
	"password" = $CitrixPassword
}

#Authenticate
Invoke-WebRequest -Uri ("https://identity.citrix.com/Utility/STS/Sign-In?ReturnUrl=%2fUtility%2fSTS%2fsaml20%2fpost-binding-response") -WebSession $websession -Method POST -Body $form -ContentType "application/x-www-form-urlencoded" -Verbose -UseBasicParsing

$download = Invoke-WebRequest -Uri ('https://secureportal.citrix.com/Licensing/Downloads/UnrestrictedDL.aspx?DLID=16110&URL=https://downloads.citrix.com/16110/VDAServerSetup_1906.exe') -WebSession $websession -MaximumRedirection 100 -Verbose -Method GET -UseBasicParsing
$webform = @{
	"chkAccept" = "on"
	"__EVENTTARGET" = "clbAccept_0"
	"__EVENTARGUMENT" = "clbAccept_0_Click"
	"__VIEWSTATE" = ($download.InputFields | Where-Object { $_.id -eq "__VIEWSTATE" }).value
	"__EVENTVALIDATION" = ($download.InputFields | Where-Object { $_.id -eq "__EVENTVALIDATION" }).value
}

#Download
Invoke-WebRequest -Uri ("https://secureportal.citrix.com/Licensing/Downloads/UnrestrictedDL.aspx?DLID=16110&URL=https%3a%2f%2fdownloads.citrix.com%2f16110%2fVDAServerSetup_1906.exe") -WebSession $websession -Method POST -Body $webform -ContentType "application/x-www-form-urlencoded" -OutFile $downloadpath -Verbose -UseBasicParsing
