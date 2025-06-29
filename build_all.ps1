param (
  [Parameter(Mandatory=$true)]
  [ValidateNotNullorEmpty()]
  [string]$Version,

  [Parameter(Mandatory=$true)]
  [ValidateNotNullorEmpty()]
  [string]$OutputFilePrefix,

  [Parameter(Mandatory=$true)]
  [ValidateNotNullorEmpty()]
  [string]$ModName,
  
  [Parameter(Mandatory=$true)]
  [ValidateNotNullorEmpty()]
  [string]$ModFilesPath,
  
  [Parameter(Mandatory=$true)]
  [ValidateNotNullorEmpty()]
  [string]$ModBaseFilesUrl,
  
  [Parameter(Mandatory=$true)]
  [ValidateNotNullorEmpty()]
  [string]$ModBaseFilesUrlHash,

  [Parameter(Mandatory=$false)]
  [string]$ModReadmePath,
  
  [Parameter(Mandatory=$true)]
  [ValidateNotNullorEmpty()]
  [string]$PublishPath
)

$CMakeOutputPath = "$PSScriptRoot/CMakeOutput" -replace "\\", "/"

$ModFolder = (Split-Path -Path $ModFilesPath -Leaf)
$ModBaseFilesPath = "$CMakeOutputPath/downloads/BaseModFiles"

# Convert to Unix path separators for CMake.
$ModFilesPath = $ModFilesPath -replace "\\", "/"
$PublishPath = "$PublishPath/release_win-x86" -replace "\\", "/" 
$ArtifactModPath = "$PublishPath/$ModFolder" -replace "\\", "/" 

Write-Host "Download base mod files to ""$ModBaseFilesPath""" -ForegroundColor Yellow
cmake `
  "-DFETCHCONTENT_BASE_DIR=$PSScriptRoot/CMakeOutput" `
  "-DCMAKE_BINARY_DIR=$PSScriptRoot/CMakeOutput" `
  "-DMOD_BASE_FILES_URL=$ModBaseFilesUrl" `
  "-DMOD_BASE_FILES_URL_HASH=$ModBaseFilesUrlHash" `
  "-DMOD_BASE_FILES_PATH=$ModBaseFilesPath" `
  -P $PSScriptRoot\CMakeLists.txt

# Delete previous artifacts.
if (Test-Path -Path "$PublishPath")
{
  Write-Host "Delete previous artifacts: ""$PublishPath""" -ForegroundColor Yellow
  Remove-Item -Path "$PublishPath\*" -Recurse -Force
}

# Create the temporary artifact mod folder
Write-Host "Create temp artifact mod folder: ""$ArtifactModPath""" -ForegroundColor Yellow
New-Item -ItemType Directory -Path $ArtifactModPath -Force | Out-Null

# Copy base mod files
Write-Host "Copy base mod files to artifacts mod folder." -ForegroundColor Yellow
Copy-Item -Path $ModBaseFilesPath\* -Destination $ArtifactModPath -Recurse -Force

# Copy updated mod files
Write-Host "Copy updated mod files to artifacts mod folder." -ForegroundColor Yellow
Copy-Item -Path $ModFilesPath\* -Destination $ArtifactModPath -Recurse -Force

# Copy licenses
New-Item -ItemType Directory -Path $ArtifactModPath\licenses -Force | Out-Null
Write-Host "Copy license files to artifacts mod folder." -ForegroundColor Yellow
Copy-Item -Path $PSScriptRoot\Installer\licenses\* -Destination $ArtifactModPath\licenses -Recurse -Force

# 1. Build the installer.

$OutputName = "$($OutputFilePrefix)_$($Version)_Windows_x86"
$OutputExe = "$OutputName.exe"

$NsisArguments = @(
  "/DNAME=""$ModName"""
  "/DCAPTION=""$ModName"""
  "/DVERSION=""$Version"""
  "/DMOD_FOLDER=""$ModFolder"""
  "/DMOD_FILES_PATH=""$ArtifactModPath"""
  "/DOUTPUTFILE=""$OutputExe"""
  "-V3"
)

if ($PSBoundParameters.ContainsKey('ModReadmePath')) {
  # No need to replace '\' with '/'
  $NsisArguments += "/DMOD_README_PATH=""$ModReadmePath"""
}

Write-Host "Build mod installer." -ForegroundColor Yellow
makensis.exe @NsisArguments $PSScriptRoot\Installer\ModInstaller.nsi

# Publish .exe to the publish path.
Write-Host "Publish mod installer to ""$PublishPath/$OutputExe""" -ForegroundColor Yellow
Move-Item -Path $PSScriptRoot\Installer\$OutputExe -Destination $PublishPath -Force

# 2. Create the mod ZIP archive.
Write-Host "Create mod ZIP archive: ""$PublishPath/$OutputName.zip""" -ForegroundColor Yellow
Compress-Archive -Path $ArtifactModPath -DestinationPath "$PublishPath/$OutputName.zip" -Update

# Delete the temporary artifact mod folder.
Write-Host "Remove temp artifact mod folder." -ForegroundColor Yellow
Remove-Item $ArtifactModPath -Recurse -Force

Write-Host "Done" -ForegroundColor Green