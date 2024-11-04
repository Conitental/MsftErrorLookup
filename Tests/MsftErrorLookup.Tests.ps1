#Requires -Modules PSScriptAnalyzer

BeforeAll {
	$ModuleRoot = "$PSScriptRoot\..\MsftErrorLookup\"

	Import-Module "$ModuleRoot\MsftErrorLookup.psm1"

	# Additionally dot source the private scripts to expose them to testing
	@(Get-ChildItem $ModuleRoot\Private\*.ps1) | Foreach-Object { . $_.FullName }
}

Describe "PSScriptAnalyzer" {
	It "should show no warnings or errors." {
		$Results = Invoke-ScriptAnalyzer -Path $ModuleRoot -Recurse
		$Results | Out-String | Write-Host
		$Results | Should -Be $null
	}
}

Describe "Get-ErrorLookupTool" {
	It "should download Error Lookup Tool" {
		Get-ErrorLookupTool
		Test-Path -Path "$($env:Temp)\MicrosoftErrorLookupTool.exe" | Should -BeTrue
	}

	It "should match the expected filehash" {
		Get-ErrorLookupTool
		Get-FileHash -Algorithm SHA256 -Path "$($env:Temp)\MicrosoftErrorLookupTool.exe" | Select-Object -ExpandProperty Hash | Should -Be '88739EC82BA16A0B4A3C83C1DD2FCA6336AD8E2A1E5F1238C085B1E86AB8834A'
	}
}

Describe "Get-MsftError" {
	It "should find access denied error message" {
		$Errors = Get-MsftError -ErrorCode 5
		$Errors.Name | Should -Contain 'ERROR_ACCESS_DENIED'
	}

	It "should output as [System.Xml.XmlNode]" {
		Get-MsftError -ErrorCode 5 -Outxml | Should -BeOfType System.Xml.XmlNode
	}
}

