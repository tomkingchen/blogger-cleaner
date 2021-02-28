# Get Google OAuth2 Token
Function Get-OauthToken {
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
  Start-Process "https://accounts.google.com/o/oauth2/v2/auth?client_id=$client_id&scope=$scopes&access_type=offline&response_type=code&redirect_uri=urn:ietf:wg:oauth:2.0:oob"    
  $code = Read-Host "Please enter the authorization code: "
  $response = Invoke-WebRequest https://www.googleapis.com/oauth2/v4/token -ContentType application/x-www-form-urlencoded -Method POST -Body "client_id=$client_id&client_secret=$client_secret&redirect_uri=urn:ietf:wg:oauth:2.0:oob&code=$code&grant_type=authorization_code"
  Return ($response.Content | ConvertFrom-Json).access_token
}

# List objects from Blogger API
Function Get-BloggerObj {
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory = 1)]
    [String]$ApiUri
  )
  $api_uri = $ApiUri
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
    [String]$ApiUri
  )
  $api_uri = $ApiUri
  $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
  $headers.Add("Accept", "application/json")
  $headers.Add("Content-Type", "application/json")
  $web_response = Invoke-RestMethod $api_uri -Method 'DELETE' -Headers $headers
  return $web_response
}

# Check for SPAM comments in Blogger posts
Function Get-SpamComments {
  [CmdletBinding()]
  param (
      [Parameter(Mandatory = 1)]
      [String]$BlogId,
      [Parameter(Mandatory = 1)]
      [String]$AccessToken
  )

  $blog_id = $BlogId
  $uri = "https://blogger.googleapis.com/v3/blogs/"+ $blog_id
  $access_token = "access_token=$AccessToken"
  $post_uri = $uri + "/posts/?" + $access_token
  $posts = Get-BloggerObj -ApiUri $post_uri
  $bad_posts = @()

  ForEach ($post in $posts){
    # Check if post has comments/replies
    if ($post.replies.totalItems -ne "0"){
      $post_title = $post.title
      $post_id = $post.id
      $comments_uri = $uri + "/posts/$post_id/comments?" + $access_token
      $comments = Get-BloggerObj -ApiUri $comments_uri
      $bad_comments = @()
      Foreach ($comment in $comments) {
        $bad_comment = New-Object PSObject
        $comment_content = $comment.content
        # Check if comment contains hyper link
        If ($comment_content -like "*href=*"){
          $bad_comment| Add-Member -NotePropertyName 'id' -NotePropertyValue $comment.id
          $bad_comment| Add-Member -NotePropertyName 'content' -NotePropertyValue $comment_content
          $bad_comment| Add-Member -NotePropertyName 'link' -NotePropertyValue $comment.selflink
          $bad_comments += $bad_comment
        }
      }
      If ($bad_comments){
        $bad_post = New-Object PSObject
        $bad_post | Add-Member -NotePropertyName 'post_id' -NotePropertyValue $post_id
        $bad_post | Add-Member -NotePropertyName 'post_title' -NotePropertyValue $post_title
        $bad_post | Add-Member -NotePropertyName 'bad_comments' -NotePropertyValue $bad_comments
        $bad_posts += $bad_post
      }
    }
  }
  return $bad_posts
}