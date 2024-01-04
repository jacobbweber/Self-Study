function Get-Regionprefix {
    [CmdletBinding()]
    param (
        # Parameter help description
        [parameter(Mandatory)]
        [ValidateSet('Production', 'Development', 'Test', 'QA', 'Stage', 'Training')]
        [string]
        $Region
    )

    process {
        switch (${Region}) {
            'Production' {
                $prefix = 'sp1-'
            }
            'Stage' {
                $prefix = 'ss1-'
            }
            'QA' {
                $prefix = 'sq1-'
            }
            'Test' {
                $prefix = 'st1-'
            }
            'Development' {
                $prefix = 'sd1-'
            }
        }
        Write-Output $prefix
    }
}
