function Get-DSDomain {
    [CmdletBinding(DefaultParameterSetName = 'Current')]
    param(
        # Domain controller to connect to when not in a domain.
        [Parameter(ParameterSetName = 'Remote',
                   Mandatory = $true)]
        [string]
        $ComputerName,

        # Credentials to use for getting domain information.
        [Parameter(ParameterSetName = 'OtherDomain',
                    Mandatory = $false)]
        [Parameter(ParameterSetName = 'Remote',
                   Mandatory = $true)]
        [Management.Automation.PSCredential]
        [Management.Automation.CredentialAttribute()]
        $Credential = [Management.Automation.PSCredential]::Empty,

        # Domain name.
        [Parameter(ParameterSetName = 'OtherDomain',
                   Mandatory = $true)]
        [string]
        $DomainName
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
                    $DomainObject = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
                    # Get sid for domain.
                    
                    $RootDN = "DC=$(($DomainObject.Name).replace('.',',DC='))"
                    $DEObj = Get-DSDirectoryEntry -DistinguishedName $RootDN
                    $Sid = (New-Object -TypeName System.Security.Principal.SecurityIdentifier($DEObj.objectSid.value,0)).value
                    $guid = "$([guid]($DEObj.objectguid.Value))"
                        
                    Add-Member -InputObject $DomainObject -MemberType NoteProperty -Name 'Sid' -Value $Sid
                    Add-Member -InputObject $DomainObject -MemberType NoteProperty -Name 'Guid' -Value $guid
                    
                    
                } else {
                    throw 'This computer is not joined to a domain so no domain could be retrieved.'
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
                $DomainObject = [DirectoryServices.ActiveDirectory.Domain]::GetDomain($context)
                
                $RootDN = "DC=$(($DomainObject.Name).replace('.',',DC='))"
                $DEObj = Get-DSDirectoryEntry -DistinguishedName $RootDN -ComputerName $ComputerName -Credential $Credential
                $Sid = (New-Object -TypeName System.Security.Principal.SecurityIdentifier($DEObj.objectSid.value,0)).value
                $guid = "$([guid]($DEObj.objectguid.Value))"

                Add-Member -InputObject $DomainObject -MemberType NoteProperty -Name 'Sid' -Value $Sid
                Add-Member -InputObject $DomainObject -MemberType NoteProperty -Name 'Guid' -Value $guid
            }

            'OtherDomain' {
                if ($Credential.UserName -ne $null){
                    # Arguments to get domain with alternate credentials
                    $cArgs = @(
                        'Domain',
                        $DomainName,
                        $Credential.UserName,
                        $Credential.GetNetworkCredential().Password
                    )
                } else {
                    # Arguments to only get domain with no alternate credentials
                    $cArgs = @(
                        'Domain',
                        $DomainName
                    )
                }
                $typeName = 'DirectoryServices.ActiveDirectory.DirectoryContext'
                $context = New-Object $typeName  $cArgs
                $DomainObject = [DirectoryServices.ActiveDirectory.Domain]::GetDomain($context)
                
                $RootDN = "DC=$(($DomainObject.Name).replace('.',',DC='))"
                if ($Credential.UserName -ne $null){
                    $DEObj = Get-DSDirectoryEntry -DistinguishedName $RootDN -Credential $Credential
                } else {
                    $DEObj = Get-DSDirectoryEntry -DistinguishedName $RootDN
                }
                $Sid = (New-Object -TypeName System.Security.Principal.SecurityIdentifier($DEObj.objectSid.value,0)).value
                $guid = "$([guid]($DEObj.objectguid.Value))"

                Add-Member -InputObject $DomainObject -MemberType NoteProperty -Name 'Sid' -Value $Sid
                Add-Member -InputObject $DomainObject -MemberType NoteProperty -Name 'Guid' -Value $guid
                
            }
            Default {}
        }
        $DomainObject
    }

    end {
    }
}