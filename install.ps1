# Install the docpack CLI on Windows from https://github.com/MaxLisaius/docpack-cli/releases
#
#   irm https://raw.githubusercontent.com/MaxLisaius/docpack-cli/main/install.ps1 | iex
#
# Options (environment variables):
#   DOCPACK_VERSION=v0.1.0      install that release instead of the latest
#   DOCPACK_INSTALL_DIR=<dir>   where docpack.exe goes (default: %LOCALAPPDATA%\docpack\bin)
#   DOCPACK_NO_MODIFY_PATH=1    do not add the install folder to your user PATH
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$repo = 'MaxLisaius/docpack-cli'
$version = $env:DOCPACK_VERSION
if (-not $version) { $version = (Invoke-RestMethod "https://api.github.com/repos/$repo/releases/latest").tag_name }
$arch = 'amd64'
if ($env:PROCESSOR_ARCHITECTURE -eq 'ARM64') { $arch = 'arm64' }

$file = "docpack_$($version.TrimStart('v'))_windows_$arch.zip"
$base = "https://github.com/$repo/releases/download/$version"
$tmp = Join-Path ([IO.Path]::GetTempPath()) ('docpack-' + [guid]::NewGuid())
New-Item -ItemType Directory -Path $tmp | Out-Null
try {
  $archive = Join-Path $tmp $file
  $sums = Join-Path $tmp 'checksums.txt'
  Invoke-WebRequest -UseBasicParsing -Uri "$base/$file" -OutFile $archive
  Invoke-WebRequest -UseBasicParsing -Uri "$base/checksums.txt" -OutFile $sums

  $line = Get-Content $sums | Where-Object { $_ -match (' ' + [regex]::Escape($file) + '$') } | Select-Object -First 1
  $want = if ($line) { ($line -split '\s+')[0].ToLower() } else { '' }
  $got = (Get-FileHash -Algorithm SHA256 $archive).Hash.ToLower()
  if (-not $want -or $want -ne $got) { throw "docpack: checksum mismatch for $file; nothing was installed." }

  Expand-Archive -Path $archive -DestinationPath $tmp -Force
  $dir = $env:DOCPACK_INSTALL_DIR
  if (-not $dir) { $dir = Join-Path $env:LOCALAPPDATA 'docpack\bin' }
  New-Item -ItemType Directory -Force -Path $dir | Out-Null
  Copy-Item (Join-Path $tmp 'docpack.exe') (Join-Path $dir 'docpack.exe') -Force
  Write-Host "docpack $version installed to $dir\docpack.exe"

  if (-not $env:DOCPACK_NO_MODIFY_PATH) {
    $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    if (-not $userPath) { $userPath = '' }
    if (($userPath -split ';') -notcontains $dir) {
      [Environment]::SetEnvironmentVariable('Path', ($userPath.TrimEnd(';') + ';' + $dir).TrimStart(';'), 'User')
      Write-Host "Added $dir to your user PATH. Open a new terminal to run docpack."
    }
  }
} finally {
  Remove-Item -Recurse -Force $tmp
}
