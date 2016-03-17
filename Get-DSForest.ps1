function Get-DSForest {
    [CmdletBinding(DefaultParameterSetName = 'Current')]
    param(
        # Domain controller to connect to when not in a domain.
        [Parameter(ParameterSetName = 'Remote',
                   Mandatory = $true)]
        [string]
        $ComputerName,
        
        # Credentials to use for getting forest information.
        [Parameter(ParameterSetName = 'Remote',
                   Mandatory = $true)]
        [Parameter(ParameterSetName = 'OtherForest',
                    Mandatory = $false)]
        [pscredential]
        $Credential,
        
        # Forest name.
        [Parameter(ParameterSetName = 'OtherForest',
                   Mandatory = $true)]
        [string]
        $ForestName
    )
    
    begin {
    }
    
    process {
        $sig = @"
[DllImport("Netapi32.dll", CharSet=CharSet.Unicode, SetLastError=true)]
public static extern int NetGetJoinInformation(string server,out IntPtr domain,out int status);
"@

        switch ($PSCmdlet.ParameterSetName) {
            'Current' {
                $type = Add-Type -MemberDefinition $sig -Name Win32Utils -Namespace NetGetJoinInformation -PassThru
                $ptr = [IntPtr]::Zero
                $joinstatus = 0
                $type::NetGetJoinInformation($null, [ref] $ptr, [ref]$joinstatus) |Out-Null
                
                if ($joinstatus -eq 3){
                    $ForestObject = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()    
                } else {
                    throw 'This computer is not joined to a domain so no forest could be retrieved.'
                }
            }
            
            'Remote' {
                
            }
            
            'OtherForest' {
                
            }
            Default {}
        }
        $ForestObject
    }
    
    end {
    }
}

