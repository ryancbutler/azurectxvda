#Kick off Dispatch Github job

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$url = "https://api.github.com/repos/ryancbutler/azurectxvda/dispatches"

#Change Github Token
$headers = @{
    "Authorization" = "token YOURTOKEN"
    "Content-Type" = "application/json"
    "Accept" = "application/vnd.github.everest-preview+json"
}

$body = @{
    "event_type" = "Deploy Message"
}

Invoke-RestMethod -Method POST -Uri $url -UseBasicParsing -Headers $headers -Body ($body|convertto-json)