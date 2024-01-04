function Get-RegionNetwork {
    [CmdletBinding()]
    param (
        # Parameter help description
        [parameter(Mandatory)]
        [ValidateSet('Production', 'Development', 'Test', 'QA', 'Stage', 'Training')]
        [string]
        $Region
    )

    process {
        switch ($region) {
            'Production' {
                $HypervSwitch = 'Production' #This is for the default hyper-v settings.
            }
            'Stage' {
                $HypervSwitch = 'stage'
            }
            'QA' {
                $HypervSwitch = 'qa'
            }
            'Test' {
                $HypervSwitch = 'test'
            }
            'Development' {
                $HypervSwitch = 'development'
            }
            'Training' {
                $HypervSwitch = 'training'
            }
        }#end DC1 region block
        Write-Output $HypervSwitch
    }
}
