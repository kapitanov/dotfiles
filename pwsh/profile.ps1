#!/usr/bin/env pwsh

$env:PATH = $env:PATH + ";."

$env:PYTHONIOENCODING = "UTF-8"
$env:LC_ALL="C.UTF-8"

$__IS_ADMIN = $false
$__user_identity = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
if ($__user_identity.IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
	$__IS_ADMIN = $true
}

function prompt
{
	write-host "PS " -n

	$loc = Get-Location
	write-host "$loc" -n -f magenta

	if ($LASTEXITCODE -ne 0 -and -not [string]::IsNullOrEmpty($LASTEXITCODE)) {
		write-host " (exit code $LASTEXITCODE)" -n -f darkred
	}
	write-host ""

	if($__IS_ADMIN) {
		write-host "#" -n -f green
	} else {
		write-host "`$" -n -f green
	}
	write-host "" -n -f white

	[System.Environment]::CurrentDirectory = $(pwd)

	$out = " "
	$out += "$([char]27)]9;12$([char]7)"

	if ($loc.Provider.Name -eq "FileSystem") {
	  $out += "$([char]27)]9;9;`"$($loc.Path)`"$([char]7)"
	}
	$out += "$([char]27)[0m"

	return "$out"
}

function sshto() {
	wsl -e sshto $args
}

[Console]::OutputEncoding = [System.Text.Encoding]::Default


# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

Import-Module DockerCompletion
Import-Module posh-git
Import-Module DockerComposeCompletion

# PowerShell parameter completion shim for the dotnet CLI 
Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
     param($commandName, $wordToComplete, $cursorPosition)
         dotnet complete --position $cursorPosition "$wordToComplete" | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
         }
}

Import-Module -Name PSKubectlCompletion
Register-KubectlCompletion
