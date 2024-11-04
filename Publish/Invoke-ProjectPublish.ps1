# Run tests before publishing
$Result = ..\Tests\Invoke-ProjectTests.ps1

If( $Result.FailedCount -ne 0 ) {
	Write-Error "Pester tests returned failures. Exiting"
	Exit
}

$PublishParameters = Get-Content .\PublishParameters.json | ConvertFrom-Json

Publish-Module @PublishParameters -Verbose -WhatIf
