function Get-DSDirectoryEntry {
[CmdletBinding(DefaultParameterSetName = 'Current')]
    param(
        # Domain controller.
        [Parameter(ParameterSetName = 'Remote',
                   Mandatory = $true)]
        [string]
        $ComputerName,
        
        # Credentials to use connection.
        [Parameter(ParameterSetName = 'Remote',
                   Mandatory = $true)]
        [Parameter(ParameterSetName = 'Alternate',
                   Mandatory = $true)]
        [Management.Automation.PSCredential]
        [Management.Automation.CredentialAttribute()]
        $Credential = [Management.Automation.PSCredential]::Empty,
        
        # Distinguished Name of AD object.
        [Parameter(Mandatory = $true)]
        [string]
        $DistinguishedName
    )

    begin {
        $sig = @"
[DllImport("Netapi32.dll", CharSet=CharSet.Unicode, SetLastError=true)]
public static extern int NetGetJoinInformation(string server,out IntPtr domain,out int status);
"@
        $type = Add-Type -MemberDefinition $sig -Name Win32Utils -Namespace NetGetJoinInformation -PassThru
        $ptr = [IntPtr]::Zero
        $joinstatus = 0
        $type::NetGetJoinInformation($null, [ref] $ptr, [ref]$joinstatus) |Out-Null
    }

    process {
        switch ( $PSCmdlet.ParameterSetName ) {
            'Current' {
                if ($joinstatus -eq 3) {
                    [adsi]"LDAP://$($DistinguishedName)"
                } else {
                    throw 'Host is currently not joined to a domain.'
                }
            }

            'Remote' {
                $fullPath = "LDAP://$($ComputerName)/$($DistinguishedName)"
                New-Object -TypeName System.DirectoryServices.DirectoryEntry -ArgumentList @($fullPath,
                    $Credential.UserName,
                    $Credential.GetNetworkCredential().Password) 
                
            }
            
            'Alternate' {
                $fullPath = "LDAP://$($DistinguishedName)"
                New-Object -TypeName System.DirectoryServices.DirectoryEntry -ArgumentList @($fullPath,
                    $Credential.UserName,
                    $Credential.GetNetworkCredential().Password) 
            }    
        }
    }

    end{}
}
