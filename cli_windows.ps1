param (
    [string]$DownloadBaseURL = 'https://github.com/secrethub/secrethub-cli/releases/download/',
    [string]$InstallPath,
    [string]$InstallDir = 'SecretHub',
    [string]$OS = "windows",
    [string]$ApplicationName = "SecretHub CLI",
    [string]$BinaryName = "secrethub"
 )

$ErrorActionPreference = "Stop"

echo "This script will install the latest version of the $ApplicationName."

If(!$InstallPath) {
    $programFilesDir = [environment]::getfolderpath("ProgramFiles")
    $InstallPath = Join-Path $programFilesDir $InstallDir
}

$licensePath = Join-Path $InstallPath LICENSE

If(!(test-path $InstallPath)){
    mkdir $InstallPath | out-null
}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$releases = "https://api.github.com/repos/secrethub/secrethub-cli/releases"
$version = (Invoke-WebRequest $releases | ConvertFrom-Json)[0].tag_name

# This will either suffix the OS with `amd64` (64-bit) or 
# `x86` (32-bit), depending on the architecture.
$ARCH = $ENV:PROCESSOR_ARCHITECTURE.ToLower()
$archiveName = $BinaryName + '-' + $version + '-' + $OS + '-' + $ARCH

# download
$archive = $archiveName + '.zip'
$archiveURL = $DownloadBaseURL + $version + '/' + $archive
$archiveFile = $ENV:TEMP + '\'+ $archive
(New-Object System.Net.WebClient).DownloadFile($archiveURL, [IO.Path]::GetFullPath($archiveFile))

# unzip
$shell = new-object -com shell.application
$source = $shell.NameSpace([IO.Path]::GetFullPath($archiveFile))
$dest = $shell.Namespace([IO.Path]::GetFullPath($InstallPath))
$dest.CopyHere($source.items(), 0x14)

# Cleanup
rm $archiveFile
$oldBinary = Join-Path -Path $InstallPath -ChildPath "secrethub.exe"
if (Test-Path $oldBinary)
{
  Remove-Item $oldBinary
}

# Adding SecretHub folder to Path...
# Check if already in Path
$envPaths = $env:Path -split ';'
$bin = Join-Path -Path $InstallPath -ChildPath "bin"
if ($envPaths -notcontains $bin) {
    $envPaths = $envPaths + $bin | where { $_ }
    $newPath = $envPaths -join ';'

    # Add it to the Path
    [Environment]::SetEnvironmentVariable("Path", $newPath, [EnvironmentVariableTarget]::User)

    # Refresh the Path
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

echo "Successfully installed $ApplicationName $version. To verify the installation, run: 

    $BinaryName --version
    
"
