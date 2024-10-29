<#
.SYNOPSIS
    Retrieves information about Microsoft error codes using the Microsoft Error Lookup Tool (ELT).

.DESCRIPTION
    The Get-MSError function allows users to look up Microsoft error codes by downloading and executing the Microsoft Error Lookup Tool (ELT). 
    It checks for the tool's presence and integrity, downloading it if necessary. The function can return results in either XML format or as a 
    custom PowerShell object containing the error code, name, source, and message.

.PARAMETER ErrorCode
    The mandatory error code to look up.

.PARAMETER OutXML
    Optional switch that, when specified, returns the output in XML format.

.PARAMETER ForceDownload
    Optional switch that forces the re-download of the Microsoft Error Lookup Tool, regardless of its current presence or validity.

.EXAMPLE
    Get-MSError -ErrorCode "0x80070005"
    Retrieves information about the specified error code and returns it as a custom object.

.EXAMPLE
    Get-MSError -ErrorCode "0x80070005" -OutXML
    Retrieves information about the specified error code and returns the output in XML format.
#>

Function Get-MSError {
    [CMDLetBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$ErrorCode,
        [switch]$OutXML,
        [switch]$ForceDownload
    )

    $ErrorLookupToolUri = 'https://download.microsoft.com/download/4/3/2/432140e8-fb6c-4145-8192-25242838c542/Err_6.4.5/Err_6.4.5.exe'

    $ExpectedPath       = "$($env:Temp)\MicrosoftErrorLookupTool.exe"
    $ExpectedFileHash   = '88739EC82BA16A0B4A3C83C1DD2FCA6336AD8E2A1E5F1238C085B1E86AB8834A'

    $FileMissing = -not (Test-Path $ExpectedPath)
    $HashMatches = (Get-FileHash -Algorithm SHA256 -Path $ExpectedPath -ErrorAction SilentlyContinue).Hash -eq $ExpectedFileHash

    # Download the ELT if not already present
    If( $FileMissing -or -not ($HashMatches) -or $ForceDownload) {
        Write-Verbose "Download Microsoft Error Lookup Tool from: $ErrorLookupToolUri"
        Invoke-WebRequest -OutFile $ExpectedPath -Uri $ErrorLookupToolUri -ErrorAction Stop
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

    If($OutXML) {
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

Export-ModuleMember Get-MSError