function Get-DSForest {
    [CmdletBinding(DefaultParameterSetName = 'Current')]
    param(
        # Domain controller to connect to when not in a domain.
        [Parameter(ParameterSetName = 'Remote',
                   Mandatory = $true)]
        [string]
        $ComputerName,
        
        # Credentials to use for getting forest information.
        [Parameter(ParameterSetName = 'OtherForest',
                    Mandatory = $false)]
        [Parameter(ParameterSetName = 'Remote',
                   Mandatory = $true)]
        [Management.Automation.PSCredential]
        [Management.Automation.CredentialAttribute()]
        $Credential = [Management.Automation.PSCredential]::Empty,
        
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
                $cArgs = @(
                    'DirectoryServer',
                    $ComputerName,
                    $Credential.UserName,
                    $Credential.GetNetworkCredential().Password
                )
                $typeName = 'DirectoryServices.ActiveDirectory.DirectoryContext'
                $context = New-Object $typeName  $cArgs
                $ForestObject = [DirectoryServices.ActiveDirectory.Forest]::GetForest($context)
            }
            
            'OtherForest' {
                if ($Credential.UserName -eq $null){
                    # Arguments to get forest with alternate credentials
                    $cArgs = @(
                        'Forest',
                        $ForestName,
                        $Credential.UserName,
                        $Credential.GetNetworkCredential().Password
                    )
                } else {
                    # Arguments to only get forest with no alternate credentials
                    $cArgs = @(
                        'Forest',
                        $ForestName
                    )
                }
                $typeName = 'DirectoryServices.ActiveDirectory.DirectoryContext'
                $context = New-Object $typeName  $cArgs
                $ForestObject = [DirectoryServices.ActiveDirectory.Forest]::GetForest($context)
            }
            Default {}
        }
        $ForestObject
    }
    
    end {
    }
}

