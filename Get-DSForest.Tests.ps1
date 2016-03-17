Param(
    [pscredentia]$Credential,
    [string]$ComputerName,
    [string]$Forest
)

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "GetCurrentForest" {
    if ((!$ComputerName) -and (!$Credential) -and (!$Forest))
    {
        It "Get current machine forest" {
            (Get-DSForest).GetType().FullName | Should Be 'System.DirectoryServices.ActiveDirectory.Forest'
        }
    }
}


