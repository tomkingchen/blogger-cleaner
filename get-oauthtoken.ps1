[CmdletBinding()]
param (
    [Parameter(Mandatory = 1)]
    [String]$ClientId,
    [Parameter(Mandatory = 1)]
    [String]$ClientSecret
)

$client_id = $ClientId
$client_secret = $clientSecret

$scopes = "https://www.googleapis.com/auth/blogger"

Start-Process "https://accounts.google.com/o/oauth2/v2/auth?client_id=$clientId&scope=$scopes&access_type=offline&response_type=code&redirect_uri=urn:ietf:wg:oauth:2.0:oob"    
 
$code = Read-Host "Please enter the code"
   
$response = Invoke-WebRequest https://www.googleapis.com/oauth2/v4/token -ContentType application/x-www-form-urlencoded -Method POST -Body "client_id=$clientid&client_secret=$clientSecret&redirect_uri=urn:ietf:wg:oauth:2.0:oob&code=$code&grant_type=authorization_code"
  
Write-Output "Refresh token: " ($response.Content | ConvertFrom-Json).refresh_token