[CmdletBinding()]
param (
    [Parameter(Mandatory = 1)]
    [String]$BlogId,
    [Parameter(Mandatory = 1)]
    [String]$ClientId,
    [Parameter(Mandatory = 1)]
    [String]$ClientSecret
)
. ./module/BloggerAPI.ps1

$token = Get-OauthToken -ClientId $ClientId -ClientSecret $ClientSecret
$bad_posts = Get-SpamComments -BlogId $BlogId -AccessToken $token
$bad_posts | Out-Host
if ($bad_posts){
  $yes = Read-Host "OK to delete these comments? [No/yes]: "
  if ($yes -eq "yes"){
    foreach ($bad_post in $bad_posts) {
      $comments = $bad_post.bad_comments
      foreach ($comment in $comments) {
        $api_uri = $comment.link
        Write-Host "Deleting " $api_uri
        $api_uri += "?access_token=" + $token
        $result = Remove-BloggerObj -ApiUri $api_uri
        if (!$result){
          Write-Host "Comment "$comment.id" Deleted"
        }else{
          Write-Host "[ERROR] Delete comment "$comment.id" Failed"
        }
      }
    }
  }else {
    Write-Host "Mission aborted!" -ForegroundColor Yellow
  }
}else {
  Write-Host "No SPAM comments found." -ForegroundColor Green
}