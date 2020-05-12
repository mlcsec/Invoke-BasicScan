function BasicScan
{
<# 
.SYNOPSIS
Basic portscanner targeting single host

.DESCRIPTION
Scans supplied IP address for common ports: 21,22,23,25,80,88,110,143,389,443,445,636,1433,3306,3389,5985,8000,8080,8200

.PARAMETER Target
Target IP address or DNS name to scan

.EXAMPLE
BasicScan -Target 192.168.0.7

.EXAMPLE
BasicScan -Target victim.lab.local
#>

    [CmdletBinding()] Param(
        [parameter(Mandatory = $true, Position = 0)]
        [string]
        $Target
    )

    $Ports = @(21,22,23,25,80,88,110,143,389,443,445,636,1433,3306,3389,5985,8000,8080,8200)
    $openPorts = @()
    $ErrorActionPreference = 'silentlycontinue'
    If(Test-Connection -BufferSize 32 -Count 1 -Quiet -ComputerName $Target){
        Foreach($P in $Ports) {
            $client = New-Object System.Net.Sockets.TcpClient
            $connect = $client.BeginConnect($Target,$P,$null,$null)
            If($client.Connected) {
                $openPorts += $P
                $client.Close() 
            }
            else {
                Start-Sleep -Milli 100
                If($client.Connected) {
                $openPorts += $P
                $client.Close()}
                }
            $client.Close()
        }
    }
    $sortedOpen = $openPorts -join ","
    $array = @()
    $object = New-Object -TypeName PSObject
    $object | Add-Member -Name 'Target' -MemberType Noteproperty -Value "$Target"
    $object | Add-Member -Name 'Ports' -MemberType Noteproperty -Value "$sortedOpen"
    $array += $object
    $array | Format-Table -Auto
}
