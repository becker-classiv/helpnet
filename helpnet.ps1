#Requires -Version 5.1
# helpnet.ps1 - quick network overview for Windows

function Write-Label($text) { Write-Host -NoNewline ('{0,-10}' -f $text) }
function Write-OK($text)    { Write-Host -NoNewline $text -ForegroundColor Green }
function Write-Bad($text)   { Write-Host -NoNewline $text -ForegroundColor Red }

# WiFi
$wifiAdapter = Get-NetAdapter | Where-Object {
    $_.Status -eq 'Up' -and (
        $_.PhysicalMediaType -like '*802.11*' -or
        $_.InterfaceDescription -like '*Wi-Fi*' -or
        $_.InterfaceDescription -like '*Wireless*'
    )
} | Select-Object -First 1

Write-Label 'WiFi:'
if ($wifiAdapter) {
    $wifiIP = (Get-NetIPAddress -InterfaceIndex $wifiAdapter.InterfaceIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue |
               Select-Object -First 1).IPAddress
    $ssidLine = netsh wlan show interfaces 2>$null | Select-String '^\s+SSID\s+:\s+(?!BSSID)(.+)'
    $ssid = if ($ssidLine) { $ssidLine.Matches[0].Groups[1].Value.Trim() } else { 'unknown' }
    if ($wifiIP) { Write-OK $wifiIP; Write-Host "  ($ssid)" }
    else         { Write-Bad 'no IP'; Write-Host '' }
} else {
    Write-Bad 'disconnected'; Write-Host ''
}

# Ethernet — discover dynamically, skip virtual/loopback/Wi-Fi
$ethAdapters = Get-NetAdapter | Where-Object {
    $_.Status -eq 'Up' -and
    $_.PhysicalMediaType -ne 'Native 802.11' -and
    $_.InterfaceDescription -notmatch 'Wi-Fi|Wireless|Virtual|Loopback|VPN|TAP|WireGuard|Tailscale' -and
    ($_.InterfaceDescription -match 'Ethernet|LAN' -or $_.MediaType -eq '802.3')
}

Write-Label 'Ethernet:'
$ethFound = $false
foreach ($eth in $ethAdapters) {
    $ethIP = (Get-NetIPAddress -InterfaceIndex $eth.InterfaceIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue |
              Select-Object -First 1).IPAddress
    if ($ethIP) {
        Write-OK $ethIP; Write-Host "  ($($eth.Name) — $($eth.InterfaceDescription))"
        $ethFound = $true
        break
    }
}
if (-not $ethFound) { Write-Bad 'disconnected'; Write-Host '' }

# Default Gateway
Write-Label 'Gateway:'
$gw = (Get-NetRoute -DestinationPrefix '0.0.0.0/0' -ErrorAction SilentlyContinue |
       Sort-Object RouteMetric | Select-Object -First 1).NextHop
Write-Host ($gw ? $gw : 'none')

# DNS
Write-Label 'DNS:'
$dns = (Get-DnsClientServerAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
        Where-Object { $_.ServerAddresses } |
        Select-Object -ExpandProperty ServerAddresses |
        Sort-Object -Unique | Select-Object -First 4) -join ' '
Write-Host ($dns ? $dns : 'none')

# Internet reachability + Public IP + Location
Write-Label 'Internet:'
try {
    $pubJson = Invoke-RestMethod -Uri 'https://ipinfo.io' -TimeoutSec 3 -ErrorAction Stop
    Write-OK 'reachable'; Write-Host ''
    Write-Label 'Public:'; Write-Host $pubJson.ip
    if ($pubJson.city) {
        Write-Label 'Location:'; Write-Host "$($pubJson.city), $($pubJson.region), $($pubJson.country)"
    }
} catch {
    Write-Bad 'unreachable'; Write-Host ''
    Write-Label 'Public:'; Write-Host 'n/a'
}

# VPN — check adapter descriptions and RAS connections
$vpnAdapter = Get-NetAdapter | Where-Object {
    $_.Status -eq 'Up' -and
    $_.InterfaceDescription -match 'VPN|TAP|WireGuard|Tailscale|OpenVPN|AnyConnect|GlobalProtect|Pulse|Fortinet'
} | Select-Object -First 1

$vpnIface = $null
$vpnIP    = $null

if ($vpnAdapter) {
    $vpnIP = (Get-NetIPAddress -InterfaceIndex $vpnAdapter.InterfaceIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue |
              Select-Object -First 1).IPAddress
    if ($vpnIP) { $vpnIface = $vpnAdapter.InterfaceDescription }
}

if (-not $vpnIface) {
    $rasConn = Get-VpnConnection -ErrorAction SilentlyContinue |
               Where-Object { $_.ConnectionStatus -eq 'Connected' } |
               Select-Object -First 1
    if ($rasConn) { $vpnIface = "RAS:$($rasConn.Name)" }
}

Write-Label 'VPN:'
if ($vpnIface -and $vpnIP) { Write-OK 'ON'; Write-Host "  ($vpnIface — $vpnIP)" }
elseif ($vpnIface)          { Write-OK 'ON'; Write-Host '' }
else                        { Write-Bad 'OFF'; Write-Host '' }
