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
        switch ($PSCmdlet.ParameterSetName) {
            'Current' { 
                $forest = Get-DSForest
            }
            'Remote' { 
                $forest = Get-DSForest -ComputerName $ComputerName -Credential $Credential
            }
            'OtherForest' {
                $forest = Get-DSForest -ComputerName $ComputerName -Credential $Credential -ForestName $ForestName
            }
            Default {}
        }



        $forest.Domains | foreach {$_.GetAllTrustRelationships()}

        Switch ($TrustTypeNumber) 
		{ 
			1 { $TrustType = "Downlevel (Windows NT domain external)"} 
			2 { $TrustType = "Uplevel (Active Directory domain - parent-child, root domain, shortcut, external, or forest)"} 
			3 { $TrustType = "MIT (non-Windows) Kerberos version 5 realm"} 
			4 { $TrustType = "DCE (Theoretical trust type - DCE refers to Open Group's Distributed Computing Environment specification)"} 
			Default { $TrustType = $TrustTypeNumber }
		} 

		#http://msdn.microsoft.com/en-us/library/cc223779.aspx
		Switch ($TrustAttributesNumber) 
		{ 
			1 { $TrustAttributes = "Non-Transitive"} 
			2 { $TrustAttributes = "Uplevel clients only (Windows 2000 or newer"} 
			4 { $TrustAttributes = "Quarantined Domain (External)"} 
			8 { $TrustAttributes = "Forest Trust"} 
			16 { $TrustAttributes = "Cross-Organizational Trust (Selective Authentication)"} 
			32 { $TrustAttributes = "Intra-Forest Trust (trust within the forest)"} 
			64 { $TrustAttributes = "Inter-Forest Trust (trust with another forest)"} 
			Default { $TrustAttributes = $TrustAttributesNumber }
		} 
				 
		#http://msdn.microsoft.com/en-us/library/cc223768.aspx
		Switch ($TrustDirectionNumber) 
		{ 
			0 { $TrustDirection = "Disabled (The trust relationship exists but has been disabled)"} 
			1 { $TrustDirection = "Inbound (TrustING domain)"} 
			2 { $TrustDirection = "Outbound (TrustED domain)"} 
			3 { $TrustDirection = "Bidirectional (two-way trust)"} 
			Default { $TrustDirection = $TrustDirectionNumber }
		}
				
    }

    end {}

}