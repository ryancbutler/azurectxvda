#Downloads Latest Citrix Opimizer from https://support.citrix.com/article/CTX224676
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

$downloadpath = "$($env:SystemRoot)\temp\CitrixOptimizer.zip"
$unzippath = "C:\Program Files (x86)\Citrix Optimizer"

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
$start = Invoke-WebRequest "https://identity.citrix.com/Utility/STS/Sign-In" -SessionVariable websession -Verbose -UseBasicParsing

#Set Form
$form = @{
	"persistent" = "1"
	"userName" = $CitrixUserName
	"loginbtn" = ""
	"password" = $CitrixPassword
	"returnURL" = "https://www.citrix.com/login/bridge?url=https%3A%2F%2Fsupport.citrix.com%2Farticle%2FCTX224676%3Fdownload"
	"errorURL" = 'https://www.citrix.com/login?url=https%3A%2F%2Fsupport.citrix.com%2Farticle%2FCTX224676%3Fdownload&err=y'
}

#Authenticate
Invoke-WebRequest -Uri ("https://identity.citrix.com/Utility/STS/Sign-In") -WebSession $websession -Method POST -Body $form -ContentType "application/x-www-form-urlencoded" -Verbose -UseBasicParsing

#Download File
Invoke-WebRequest -WebSession $websession -Uri "https://phoenix.citrix.com/supportkc/filedownload?uri=/filedownload/CTX224676/CitrixOptimizer.zip" -OutFile $downloadpath -Verbose -UseBasicParsing

#Unzip Optimizer. Requires 7-zip!
7z.exe x $downloadpath -o"$unzippath" -y
