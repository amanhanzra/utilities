# Set age of files to delete
$limit = (Get-Date).AddDays(-30)

# Set directory path
$path = "C:\Users\ahanzra\Downloads" 

# set file extension to delete
$include = @("*.log","")

# Delete files older than the $limit
Get-ChildItem -Path $path -Recurse -Force -Include $include | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $limit } | Remove-Item -Force
