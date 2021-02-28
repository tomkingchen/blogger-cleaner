# List objects from Blogger API
Function Get-BloggerObj {
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory = 1)]
    [String]$api_uri
  )
  $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
  $headers.Add("Accept", "application/json")
  $headers.Add("Content-Type", "application/json")
  $base_uri = $api_uri
  do {
    $web_response = Invoke-RestMethod $api_uri -Method 'GET' -Headers $headers
    $page_token = "pageToken=" + $web_response.nextPageToken
    $api_uri = $base_uri + "&" + $page_token
    $results += $web_response.items
  } while ($web_response.nextPageToken)
  return $results
}

# Delete object in Blogger API
Function Remove-BloggerObj {
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory = 1)]
    [String]$api_uri
  )
  $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
  $headers.Add("Accept", "application/json")
  $headers.Add("Content-Type", "application/json")
  $web_response = Invoke-RestMethod $api_uri -Method 'DELETE' -Headers $headers
  return $web_response
}