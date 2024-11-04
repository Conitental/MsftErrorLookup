Function Read-HostChoice {
	<#
	  .SYNOPSIS
	  Ask for a selection of different choices.

	  .PARAMETER Title
	  The title of the prompt.

	  .PARAMETER Message
	  The message of the prompt.

	  .PARAMETER Choices
	  An array of strings that resemble the available choices

	  .PARAMETER DefaultChoice
	  The index of the choice that should be selected by default.

	  .PARAMETER EnableHotKeys
	  This switch will prepend the choices with an ampersand to use the first character as the choices hotkey

	  .PARAMETER ReturnChoiceAsString
	  With this switch enabled you will have the choices string returned instead of the index.

	  .EXAMPLE
	  Read-HostChoice -Title 'Fruits' -Message 'Select your favorite fruit!' -Choices 'Banana', 'Apple', 'Rubber Ducks'
	#>

	[cmdletbinding()]
	Param (
		[Parameter(Mandatory=$true)]
		[String]$Title,

		[Parameter(Mandatory=$true)]
		[String]$Message,

		[Parameter(Mandatory=$true)]
		[String[]]$Choices,

		[ValidateScript({ $_ -le ($Choices.Count - 1) -and $_ -ge 0 })]
		[Int]$DefaultChoice = 0,

		[Switch]$EnableHotKeys,

		[Switch]$ReturnChoiceAsString
	)

	If($EnableHotKeys) {
		# Prepend all choices with an ampersand to use the first character as hotkey
		$Choices = Foreach($Choice in $Choices) {
			If($Choice -notmatch '^&') {
				Write-Output "&$Choice"
			}
		}
	}

	$Options = [System.Management.Automation.Host.ChoiceDescription[]] $Choices

	$Result = $Host.UI.PromptForChoice($Title, $Message, $Options, $DefaultChoice)

	If($ReturnChoiceAsString) {
		Return $Choices[$Result]
	} Else {
		Return $Result
	}
}