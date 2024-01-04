function New-WSFC {
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
        [string]
        $ClusterName,

        [parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Nodes,

        [parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Network,

        [parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [string]
        $LogPath
    )

    process {
        try {
            Write-Log -Message 'Running Get-IPAMAddress to determine if DNS already exists' -Path $LogPath -Level 'Info'
            $ClusteripTable = Get-IPAMDNSAddress $ClusterName -LogPath $LogPath
            if ([string]::IsNullOrWhiteSpace($ClusteripTable.Data) -eq $false -and $ClusteripTable.Name -eq $ClusterName) {
                Write-Log -Message 'DNS already existed, using existing IP address' -Path $LogPath -Level 'Info'
                $ClusterIP = $ClusteripTable.Data
            } else {
                Write-Log -Message 'Running Get-NextFreeAddress to obtain an free IP' -Path $LogPath -Level 'Info'
                $ClusterIP = Get-NextFreeAddress -Network $Network -LogPath $LogPath
            }
            Write-Log -Message "The IP for $ClusterName is $ClusterIP" -Path $LogPath -Level 'Info'

            Write-Log -Message 'Running New-Cluster' -Path $LogPath -Level 'Info'
            FailoverClusters\New-Cluster -Name "CN=$ClusterName, OU=Comp Service Accounts, DC=willywonka, DC=com" -Node $Nodes -StaticAddress "$ClusterIP" -NoStorage -ErrorAction 'Stop'
        } catch {
            Write-Log -Message 'There was an error running New-Cluster' -Path $LogPath -Level 'Info'
            throw $PSItem.Exception.Message
        }
    }
}