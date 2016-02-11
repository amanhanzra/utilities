<#
Task: Install and configure .NET application on IIS Server
Version: 1
Author: Aman

Prerequisites:
Set-ExecutionPolicy RemoteSigned
#>


#Record Output of this script into a text file
 Start-Transcript -Path C:\SetupScriptLog.txt

#Define Variable
 Write-Verbose "Variable declared"
    $AppCode = "C:\SourceCode"
    $TempSSLDirectory = "C:\Temp\SSLCertificateDirectory"
    $AppDirectory = "C:\inetpub\Sites\DemoApp"

    $AppPoolName = "DemoAppPool"
    $AppPoolDotNetVersion = "v4.5"
    $AppName = "DemoApp.com"

#Create Directories
 Write-Verbose "Creating new directories"
    New-Item -path $AppCode -Type Directory
    New-Item -path $TempSSLDirectory -Type Directory

#Import ServerManager module
 Write-Verbose "Importing ServerManager Module"
    Import-Module ServerManager

#Install WebServer Components
 Write-Verbose "Installing Web Server Components"
	Install-WindowsFeature Web-Server -IncludeManagementTools -Verbose
	Install-WindowsFeature Web-Log-Libraries,Web-Request-Monitor,Web-Http-Redirect,Web-Http-Tracing, `
        Web-Dyn-Compression,Web-IP-Security,Web-Url-Auth,Web-App-Dev,Web-Asp-Net,WAS,WAS-Process-Model,`
        Web-Scripting-Tools,Web-Mgmt-Service -IncludeAllSubFeature -Verbose

#Import WebAdministration Module
 Write-Verbose "Importing Webadministration Module"
    Import-Module WebAdministration

#Stop IIS Services
 Write-Verbose "Stopping IIS"
    Invoke-Expression -Command "iisreset /stop" -ErrorAction Stop | Out-Host

#check if the App Pool already exists
 Write-Verbose "Checking Application Pool"
    cd IIS:\AppPools\
    if (!(Test-Path $AppPoolName -pathType container))
        {
          Write-Verbose "Creating new App Pool"
          $NewPool = New-Item $AppPoolName
          $NewPool | Set-ItemProperty -Name "managedRuntimeVersion" -Value $AppPoolDotNetVersion
        }

#check if the site exists
    cd IIS:\Sites\
    if (Test-Path $AppName -PathType container)
        {
          return
        }

#Create new IIS Web App and Binding
 Write-Verbose " Creating new web application and binding"
    $NewApp = New-Item $AppName -Bindings @{protocol="http";bindingInformation=":80:" + $AppName} -PhysicalPath $AppDirectory
    $NewApp = New-Item $AppName -bindings @{protocol="https";bindingInformation=":443:" + $AppName} -PhysicalPath $AppDirectory
    "Assigning App Pool"
    $NewApp | Set-ItemProperty -Name "applicationPool" -Value $AppPoolName

#Import SSL Certification
 Write-Verbose "Importing SSL Certificate"
    Import-Certificate -FilePath $TempSSLDirectory\DemoAppSSLCertificate.pfx -CertStoreLocation 'Cert:\LocalMachine\My'

#Assign SSL Certificate
 Write-Verbose "Assigning SSL Certificate"
    New-WebBinding -name $Name -Protocol https -HostHeader "$Name.DemoApp.com" -Port 443 -SslFlags 1
    $cert = Get-ChildItem -Path Cert:\LocalMachine\My | where-Object {$_.subject -like "*demoapp.com*"}
    New-Item -Path "IIS:\SslBindings\!443!$Name.DemoApp.com" -Value $cert -SSLFlags 1

#Remove SSL Certificate from local drive
 Write-Verbose "Deleting local SSL Directory"
    Remove-item -Force $TempSSLDirectory

#Resetting IIS
 Write-Verbose " Resetting IIS"
    $Command = "IISRESET"
    Invoke-Expression -Command $Command

#Stop Output writing
Stop-Transcript

#End