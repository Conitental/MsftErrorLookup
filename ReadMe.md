<div align="center">

# MsftErrorLookup

Lookup Microsoft Error Codes by using the Error Lookup Tool

</div>

## Installation

*MsftErrorLookup* is available on the PowerShell Gallery. Use the following command to install it:

```powershell
Install-Module -Name MsftErrorLookup -Scope CurrentUser
```

## Usage

To look up an error code, use the following command:

```powershell
Get-MsftError -ErrorCode "0x80070005"
```

This command retrieves information about the specified error code and returns it as a custom PowerShell object containing the error code, name, source, and message.

## Parameters

- `-ErrorCode`: (Mandatory) Specifies the error code you want to look up. This parameter is required for the function to execute.
- `-OutXml`: (Optional) When specified, returns the output in XML format instead of a custom PowerShell object.
- `-ForceDownload`: (Optional) Forces a re-download of the Microsoft Error Lookup Tool, regardless of its current presence or validity.
