Function Get-ErrorLookupTool {
	<#
	.SYNOPSIS
	Downloads the Microsoft Error Lookup Tool executable from a specified URI and saves it to a designated file path.
	#>

	param(
		[string]$FilePath = "$($env:Temp)\MicrosoftErrorLookupTool.exe",
		[string]$DownloadUri = 'https://download.microsoft.com/download/4/3/2/432140e8-fb6c-4145-8192-25242838c542/Err_6.4.5/Err_6.4.5.exe'
	)

	Write-Verbose "Download Microsoft Error Lookup Tool from: $DownloadUri"
	Invoke-WebRequest -OutFile $FilePath -Uri $DownloadUri -ErrorAction Stop
}
