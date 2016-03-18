﻿param(

    [string]
    $ComputerName,
        
    [Management.Automation.PSCredential]
    [Management.Automation.CredentialAttribute()]
    $Credential = [Management.Automation.PSCredential]::Empty,

    [string]
    $ForestName
)

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

$sig = @"
[DllImport("Netapi32.dll", CharSet=CharSet.Unicode, SetLastError=true)]
public static extern int NetGetJoinInformation(string server,out IntPtr domain,out int status);
"@
                

Describe "Get-DSForest" {
    $type = Add-Type -MemberDefinition $sig -Name Win32Utils -Namespace NetGetJoinInformation -PassThru
    $ptr = [IntPtr]::Zero
    $joinstatus = 0
    $type::NetGetJoinInformation($null, [ref] $ptr, [ref]$joinstatus) |Out-Null
    
    # Test for getting the forrest for which the machine is a member of.
    if ($joinstatus -eq 3)
    {
        It "Get current machine forest" {
            (Get-DSForest).GetType().FullName | Should Be 'System.DirectoryServices.ActiveDirectory.Forest'
        }
    }else {
        It 'Fails to get forest because host is not domain joined' {
            {Get-DSForest} | Should Throw 'This computer is not joined to a domain so no forest could be retrieved.'
        }
    }
    
    # Test by connecting to remote domain controller to get the forest it is a member off.
    if ($ComputerName.length -gt 0 -and $Credential.Username -ne $null) {
        It 'Get remote forest'{
             $ForestObject = Get-DSForest -ComputerName $ComputerName -Credential $Credential
             {$ForestObject -is [System.DirectoryServices.ActiveDirectory.Forest]} | Should Be $true
        }   
    }
}


