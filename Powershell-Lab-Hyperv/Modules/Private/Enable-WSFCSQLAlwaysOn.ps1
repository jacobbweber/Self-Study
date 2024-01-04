function Enable-WSFCSQLAlwaysOn {
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
        $ComputerName,

        [parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [string]
        $LogPath
    )

    process {
        foreach ($i in $ComputerName) {
            try {
                Write-Log -Message "Running Invoke-Command to Enable-SQLAlwaysOn on Computer: $i" -Path $LogPath -Level 'Info'
                Invoke-Command -ComputerName $i -ScriptBlock {
                    Enable-SqlAlwaysOn -ServerInstance $Using:i -Force
                } -ErrorAction 'Stop'
            } catch {
                Write-Log -Message "There was an error running Invoke-Command to Enable-SQLAlwaysOn on Computer: $i" -Path $LogPath -Level 'Info'
                throw $PSItem.Exception.Message
            }
        }
    }
}
