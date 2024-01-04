function New-WSFCListener {
    <#
    .SYNOPSIS
        Short description
    .DESCRIPTION
        Long description
    .EXAMPLE
        Example of how to use this cmdlet
    .EXAMPLE
        Another example of how to use this cmdlet
    #>

    [CmdletBinding()]
    param (
        [parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Listeners,

        [parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [string]
        $LogPath
    )

    process {
        foreach ($i in $Listeners) {
            try {
                Write-Log -Message "Creating a new Listener AD Object: $i" -Path $LogPath -Level 'Info'
                New-ADComputer -Name $i -SamAccountName "$i" -Path 'OU=Comp Service Accounts,DC=willywonka,DC=com' -ErrorAction 'Stop'
            } catch {
                Write-Log -Message 'There was an error creating the ADComuterObject' -Path $LogPath -Level 'Info'
                throw $PSItem.Exception.Message
            }

            try {
                $ListenerTable = Get-IPAMDNSAddress $i -LogPath $LogPath
                if ([string]::IsNullOrWhiteSpace($ListenerTable) -eq $false -and $ListenerTable.name -eq $i) {
                    $listenerIP = $ListenerTable.data
                } else {
                    $listenerIP = Get-NextFreeAddress -Network $network -LogPath $LogPath
                }
                Write-Log -Message "The IP for $i is $listenerIP" -Path $LogPath -Level 'Info'
            } catch {
                Write-Log -Message 'There was an error running Get-IPAMDNAddress' -Path $LogPath -Level 'Info'
                throw $PSItem.Exception.Message
            }

            $Results += [PSCustomObject]@{
                ListenerName = $i
                ListenerIP   = $listenerIP
            }
            $Results
        }
    }

}