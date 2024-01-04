function New-WindowsCluster {
    <#
      .SYNOPSIS
        Configures a Windows Server Failover-Cluster with SQL Always-On
      .DESCRIPTION
        This function will systematically complete each step required to configure a Windows Server Failover Cluster with SQL Always-On enabled.
      .EXAMPLE
        C:\PS>Start-WSFCBuildCluster -ClusterDefinition .\yourjson.json
      .EXAMPLE
        C:\PS>Start-WSFCBuildCluster -Nodes 'st1-server1', 'st1-server2' -clustername 'st1-serverc' -listeners 'st1-serverld1' -region 'Test'
      .EXAMPLE
        C:\PS>Start-WSFCBuildCluster -nodes 'st1-server1', 'st1-server2' -clustername 'st1-serverc' -listeners 'st1-serverld1' -region 'Test' -witnesspath '\\yourdifferentfileshare\folder\' -Logging
      .Notes
        WSFC stands for Windows Server Failover Cluster, and is used throughout this script and its modules.
        The following naming standards apply to WSFC. 
        Cluster name always ends in C (cluster)
        Listener Device always ends in LD1 (Listener Device 1,2,3,etc)
        All clusters use a dedicated file share for cluster nodes to meet quorum. "\\sp1-wsfcwit1\witnesses$" if this needs to be changed be sure to work with data services before proceeding.
    #>

    [cmdletbinding()]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'Json')]
        [ValidateNotNullOrEmpty()]
        [string]
        $ClusterDefinition,

        [Parameter(Mandatory = $true, ParameterSetName = 'Input')]
        [ValidateNotNullOrEmpty()]
        [string]
        $ClusterName,

        [Parameter(Mandatory = $true, ParameterSetName = 'Input')]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Nodes,

        [Parameter(Mandatory = $true, ParameterSetName = 'Input')]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Listeners,

        [Parameter(Mandatory = $true, ParameterSetName = 'Input')]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Region,

        [Parameter(ParameterSetName = 'Input')]
        [ValidateNotNullOrEmpty()]
        [string]
        $WitnessPath = '\\witnessserv1\witnesses$', #default

        [Parameter(ParameterSetName = 'Input')]
        [switch]
        $Logging
    )

    $StartDate = Get-Date -Format 'yyyyMMdd'

    if ($PSCMDlet.ParameterSetName -eq 'Json') {
        $ClusterName = ($ClusterDefinition.ClusterName).ToUpper()
        $Nodes = $ClusterDefinition.Nodes
        $Listeners = $ClusterDefinition.Listeners
        $WitnessPath = $ClusterDefinition.WitnessPath
        $Region = $ClusterDefinition.Region
        $WitnessADGroup = 'witnesses_full'
        $LogPath = $PSScriptRoot + '\logs\' + $ClusterName + '_' + $StartDate + '.log'
        $TranscriptLogPath = $PSScriptRoot + '\logs\' + $ClusterName + '_' + $StartDate + '_transcript.log'
    }

    if ($logging.IsPresent) {
        $LogPath = $PSScriptRoot + '\logs\' + $ClusterName + '_' + $StartDate + '.log'
        $TranscriptLogPath = $PSScriptRoot + '\logs\' + $ClusterName + '_' + $StartDate + '_transcript.log'
    } else {
        $LogPath = Read-Host -Prompt 'Oops summarized logging is required,Please enter a complete path for your log summary,including filename, eg c:\logs\willy.log'
        $TranscriptLogPath = Read-Host -Prompt 'Oh hey detailed logging is required as well,Please enter a complete path for your log details,including filename, eg c:\logs\willydetails.log'
    }

    Write-Log -Message 'Starting Cluster Creation' -Path $LogPath -Level 'Info'

    Write-Log -Message 'Starting transcript logging' -Path $LogPath -Level 'Info'
    Start-Transcript -Path $TranscriptLogPath -Append

    Write-Log -Message 'Checking for FailoverClusters' -Path $LogPath -Level 'Info'
    Confirm-WSFCPSModule -LogPath $LogPath

    Write-Log -Message "Assigning the network for region: $Region" -Path $LogPath -Level 'Info'
    $Network = Get-RegionNetwork -Region $Region

    Write-Log -Message 'Installing WSFC features on remote server(s)' -Path $LogPath -Level 'Info'
    Add-WSFCFeatures -ComputerName $Nodes -Confirm:$false -LogPath $LogPath

    Write-Log -Message 'Testing Cluster' -Path $LogPath -Level 'Info'
    Confirm-WSFCRediness -ComputerName $Nodes -LogPath $LogPath

    Write-Log -Message "Creating the Cluster: $ClusterName" -LogPath $LogPath -Level 'Info'
    New-WSFC -ClusterName $ClusterName -Nodes $Nodes -Network $Network -LogPath $LogPath

    Write-Log -Message "Configuring Cluster Quorum on $ClusterName" -LogPath $LogPath
    Set-WSFClusterQuorum -ClusterName $ClusterName -WitnessPath $WitnessPath -LogPath $LogPath

    Write-Log -Message "Adding $ClusterName to AD group witnesses_full" -Path $LogPath -Level 'Info'
    Add-ADGroupMember -Identity $WitnessADGroup -Members (Get-ADComputer -Identity $clustername)

    Write-Log -Message 'Creating a new listener' -Path $LogPath -Level 'Info'
    $ListernerDevices = New-WSFCListener -Listener $Listeners -Network $Network -LogPath $LogPath

    Write-Log -Message 'Adding Cluster Permission on the listener' -Path $LogPath -Level 'Info'
    Set-WFSClusterPermission -ClusterName $ClusterName -Listener $Listeners -LogPath $LogPath

    Write-Log -Message 'Configuring cluster properties' -Path $LogPath -Level 'Info'
    Set-WSFClusterProperties -ClusterName $ClusterName -LogPath $LogPath

    Write-Log -Message 'Enabling SQL Always-On on each node' -Path $LogPath -Level 'Info'
    Enable-WSFCSQLAlwaysOn -Node $Nodes -LogPath $LogPath

    $ClusterProperties = FailoverClusters\Get-Cluster $ClusterName

    $clusterInformation = [pscustomobject]@{
        ClusterName          = $ClusterName
        ClusterIP            = $ClusterIP
        Nodes                = $Nodes
        WitnessPath          = $WitnessPath
        SameSubnetThreshold  = $ClusterProperties.SameSubnetThreshold
        CrossSubnetDelay     = $ClusterProperties.CrossSubnetDelay
        CrossSubnetThreshold = $ClusterProperties.CrossSubnetThreshold
        RouteHistoryLength   = $ClusterProperties.RouteHistoryLength
    }

    $ClusterInformation
    $ListernerDevices

    Stop-Transcript


  }