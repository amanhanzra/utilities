$Date = Get-Date -Format yyyy.MMMM.d 
$BackupDir = "C:\Backup" 
$ZippedFiles = "C:\RemoteBackupFiles"

#FTP Server Credentials
$UserName = "username"
$Password = "password"
   
#Delete previous night zipped backup files
Remove-Item -Recurse -Force $ZippedFiles
  
#Create new directory for zipped files
New-Item -path $ZippedFiles\$Date -Type Directory
   
# Get backup files older than two days
$Files=get-childitem -Path $Backupdir -Recurse -File | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt ($(Get-Date).AddDays(–2)) } | Remove-Item -Force

# Create 7-Zip application alias and update env path
Set-Alias zg “$env:ProgramFiles\7-Zip\7zG.exe”

#start timer
$StartTime = $(Get-Date -UFormat %s)

#Zip Backup Files, split into 100mb size
ForEach ($item in $Files)
      {
          zg a -mx=5 -v100m ($item.Fullname + “.zip”) $item.FullName
      }

#Instantiate a WebClient object.
$WebClient = New-Object System.Net.WebClient

#Update credentials property of webclient to store user credentials
$WebClient.Credentials = New-Object System.Net.NetworkCredential($UserName, $Password)


foreach ($i in Get-ChildItem $ZippedFiles)
{
  $file = “$ZippedFiles\$Date\”
  
$uri = New-Object System.Uri(“ftp://192.168.150.111/$Date”)
$webclient.UploadData($uri, $file)
}

#Stop timer
$EndTime = $(Get-Date -UFormat %s)

#Calculate elapsed time
$ElapsedTime = $EndTime - $StartTime
"Elapsed time ($ElapsedTime)"

#End