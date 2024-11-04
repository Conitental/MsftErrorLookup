# Module manifest docs: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_module_manifests

@{

  RootModule = 'MsftErrorLookup.psm1'
  ModuleVersion = '1.0.0'
  GUID = 'a4a1d707-e11f-4f43-8228-7d11409cdb60'
  Author = 'Conitental'
  Description = 'Use the MsftErrorLookup module to look up Microsoft error codes by leveraging the functionality of Microsofts Error Lookup Tool.'

  FunctionsToExport = @(
    'Get-MsftError'
  )

}
