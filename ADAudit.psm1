# Importing module files
. $PSScriptRoot\Get-DSForest.ps1
. $PSScriptRoot\Get-DSDirectoryEntry.ps1
. $PSScriptRoot\Get-DSDirectorySearcher.ps1
. $PSScriptRoot\Get-DSComputer.ps1
. $PSScriptRoot\Get-DSDomain.ps1
. $PSScriptRoot\Get-DSGpo.ps1
. $PSScriptRoot\Get-DSUser.ps1
. $PSScriptRoot\Get-DSReplicationAttribute.ps1
. $PSScriptRoot\Get-DSGroup.ps1
. $PSScriptRoot\Get-DSGroupMember.ps1
. $PSScriptRoot\Get-DSOU.ps1
. $PSScriptRoot\Get-DSTrust.ps1
# Private Functions

<#
.Synopsis
   Resolve a given hostname or DQDN using DNSServer configured on host.
.DESCRIPTION
   Resolve a given hostname or DQDN using DNSServer configured on host.
.EXAMPLE
   Example of how to use this cmdlet
#>
function Get-ADIPAddress
{
    [CmdletBinding()]
    [OutputType([string[]])]
    Param
    (
        # Computer name or FQDN to resolve
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $ComputerName
    )

    Begin
    {
    }
    Process
    {
        Try
        {
            $IPArray = ([Net.Dns]::GetHostEntry($ComputerName)).AddressList
            foreach ($IPa in $IPArray)
            {
                $IPa.IPAddressToString
            }
        }
        Catch
        {
            Write-Verbose -Message "Could not resolve $($computerName)"
        }
    }
    End
    {
    }
}