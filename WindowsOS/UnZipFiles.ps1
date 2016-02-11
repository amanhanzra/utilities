<# 
Task: UnZip files using Powershell 3/4
Version: 1

#>

#Define Variable
$Source = " "
$Destination = " "

#UnZip files
#Use ExtractToDirectory static method from [io.compression.zipfile] .NET Framework class
#Add the System.IO.Compression.FileSystem assembly, use Add-Type cmdlet and specify the –Assembly parameter
Write-Verbose "Unzipping Files"    
Add-Type -assembly “system.io.compression.filesystem”
[io.compression.zipfile]::ExtractToDirectory($Source, $Destination)


<# PowerShell Version 5 has inbuild function

#To uncompress
Expand-Archive -Path C:\Scripts\one.zip  -DestinationPath C:\Scripts

#If you need to overwrite files
Expand-Archive -Path C:\Scripts\one.zip  -DestinationPath c:\Scripts -Force
#>