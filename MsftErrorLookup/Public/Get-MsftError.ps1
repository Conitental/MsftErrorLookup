Function Get-MsftError {
	<#
	.SYNOPSIS
		Retrieves information about Microsoft error codes using the Microsoft Error Lookup Tool (ERT).

	.DESCRIPTION
		The Get-MSError function allows users to look up Microsoft error codes by downloading and executing the Microsoft Error Lookup Tool (ERT).
		It checks for the tool's presence and integrity, downloading it if necessary. The function can return results in either XML format or as a
		custom PowerShell object containing the error code, name, source, and message.

	.PARAMETER ErrorCode
		The mandatory error code to look up.

	.PARAMETER OutXml
		Optional switch that, when specified, returns the output in XML format.

	.PARAMETER ForceDownload
		Optional switch that forces the re-download of the Microsoft Error Lookup Tool, regardless of its current presence or validity.

	.EXAMPLE
		Get-MSError -ErrorCode "0x80070005"
		Retrieves information about the specified error code and returns it as a custom object.

	.EXAMPLE
		Get-MSError -ErrorCode "0x80070005" -OutXml
		Retrieves information about the specified error code and returns the output in XML format.
	#>

	[CMDLetBinding()]
	param(
		[Parameter(Mandatory=$true)]
		[string]$ErrorCode,
		[switch]$OutXml,
		[switch]$ForceDownload
	)

	$ExpectedPath       = "$($env:Temp)\MicrosoftErrorLookupTool.exe"
	$ExpectedFileHash   = '88739EC82BA16A0B4A3C83C1DD2FCA6336AD8E2A1E5F1238C085B1E86AB8834A'

	$FileMissing = -not (Test-Path $ExpectedPath)
	$HashMatches = (Get-FileHash -Algorithm SHA256 -Path $ExpectedPath -ErrorAction SilentlyContinue).Hash -eq $ExpectedFileHash

	If( $ForceDownload ) {
		Get-ErrorLookupTool

	} ElseIf( $FileMissing ) {
		$Choice = Read-HostChoice -Title 'Missing Error Lookup Tool' -Choices 'Yes', 'Cancel' -EnableHotKeys -Message "Could not find Error Lookup Tool. Do you want to download it now from Microsoft?"

		Switch($Choice) {
			0 { Get-ErrorLookupTool }
			default { Return }
		}

	} ElseIf ( -not ($HashMatches) ) {
		$Choice = Read-HostChoice -Title 'Hash Mismatch' -Choices 'Yes', 'Ignore', 'Cancel' -EnableHotKey -Message "The filehash of the found ERT does not match the expected. Do you want to download it now from Microsoft?"

		Switch($Choice) {
			0 { Get-ErrorLookupTool }
			1 { Write-Verbose "Ignore hash mismatch" }
			default { Return }
		}
	}

	$ProcessInfo = New-Object System.Diagnostics.ProcessStartInfo

	$ProcessInfo.FileName               = $ExpectedPath
	$ProcessInfo.RedirectStandardError  = $true
	$ProcessInfo.RedirectStandardOutput = $true
	$ProcessInfo.UseShellExecute        = $false
	$ProcessInfo.Arguments              = '/:xml ' + $ErrorCode

	$Process = New-Object System.Diagnostics.Process
	$Process.StartInfo = $ProcessInfo

	$Process.Start() | Out-Null

	$Process.WaitForExit()
	[xml]$xml = $Process.StandardOutput.ReadToEnd()

	If($OutXml) {
		Return $xml
	}

	$Nodes = $xml | Select-Xml "//err" | Select-Object -ExpandProperty 'Node'

	Foreach($ErrorObject in $Nodes) {
		$Code = $ErrorObject | Select-Object -ExpandProperty n -ErrorAction SilentlyContinue
		$Name = $ErrorObject | Select-Object -ExpandProperty name -ErrorAction SilentlyContinue
		$Source = $ErrorObject | Select-Object -ExpandProperty src -ErrorAction SilentlyContinue
		$Message = $ErrorObject | Select-Object -ExpandProperty '#text' -ErrorAction SilentlyContinue

		[pscustomobject]@{
			Code    = $Code
			Name    = $Name
			Source  = $Source
			Message = $Message
		}
	}
}
