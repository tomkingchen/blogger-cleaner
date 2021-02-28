[CmdletBinding()]
param (
    [Parameter(Mandatory = 1)]
    [String]$BlogId,
    [Parameter(Mandatory = 1)]
    [String]$APIKey
)
. ./module/BloggerAPI.ps1

$bad_posts = ./check-spam.ps1 -BlogId $BlogId -APIKey $APIKey
foreach ($bad_post in $bad_posts) {
  $comments = $bad_post.bad_comments
  foreach ($comment in $comments) {
    $api_uri = $comment.link
    Write-Host "Deleting " $api_uri
    $api_uri += "?key=" + $APIKey
    $result = Remove-BloggerObj -api_uri $api_uri
    if (!$result){
      Write-Host "Comment "$comment.id" Deleted"
    }
  }
}