# Check for SPAM comments in Blogger posts
[CmdletBinding()]
param (
    [Parameter(Mandatory = 1)]
    [String]$BlogId,
    [Parameter(Mandatory = 1)]
    [String]$APIKey
)

. ./module/BloggerAPI.ps1

$blog_id = $BlogId

$uri = "https://blogger.googleapis.com/v3/blogs/"+ $blog_id
$api_key = "key=$APIKey"
$post_uri = $uri + "/posts/?" + $api_key
$posts = Get-BloggerObj -api_uri $post_uri
$bad_posts = @()

ForEach ($post in $posts){
  # Check if post has comments/replies
  if ($post.replies.totalItems -ne "0"){
    $post_title = $post.title
    $post_id = $post.id
    $comments_uri = $uri + "/posts/$post_id/comments?" + $api_key
    $comments = Get-BloggerObj -api_uri $comments_uri
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

$bad_posts
