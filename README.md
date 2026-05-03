# helpnet

Quick network overview for macOS, Linux, and Windows. One command to see WiFi, Ethernet, gateway, DNS, internet reachability, public IP, and VPN status.

```
WiFi:     192.168.1.210  (MyNetwork)
Ethernet: 192.168.1.170  (en11 — USB 10/100/1G/2.5G LAN)
Gateway:  192.168.1.1
DNS:      192.168.1.1
Internet: reachable
Public:   203.0.113.42
Location: Denver, Colorado, US
VPN:      ON  (utun11 — 100.90.103.30)
```

## Install

**macOS**
```bash
curl -fsSL https://raw.githubusercontent.com/becker-classiv/helpnet/main/helpnet -o /usr/local/bin/helpnet
chmod +x /usr/local/bin/helpnet
```

**Linux**
```bash
curl -fsSL https://raw.githubusercontent.com/becker-classiv/helpnet/main/helpnet-linux -o /usr/local/bin/helpnet
chmod +x /usr/local/bin/helpnet
```

**Windows** — run this once in PowerShell (no admin required):
```powershell
$dest = "$env:LOCALAPPDATA\Microsoft\WindowsApps"
Invoke-WebRequest https://raw.githubusercontent.com/becker-classiv/helpnet/main/helpnet.ps1 -OutFile "$dest\helpnet.ps1"
Invoke-WebRequest https://raw.githubusercontent.com/becker-classiv/helpnet/main/helpnet.bat -OutFile "$dest\helpnet.bat"
```

Then just type `helpnet` in any terminal. `WindowsApps` is in `PATH` by default on Windows 10+.

## What it shows

| Field | Details |
|-------|---------|
| WiFi | IP address and SSID of the active wireless interface |
| Ethernet | IP, interface name, and adapter label — discovers dynamically, handles USB/Thunderbolt adapters at any interface number |
| Gateway | Default route gateway |
| DNS | Active nameservers |
| Internet | Reachable/unreachable based on a live HTTPS check |
| Public | Your external IP via [ipinfo.io](https://ipinfo.io) |
| Location | City, region, country from ipinfo.io |
| VPN | On/off with interface name and IP — checks `utun` (macOS), `tun/tap/wg/tailscale` (Linux), adapter descriptions and RAS connections (Windows) |

## Platform notes

**macOS** — uses `ipconfig`, `networksetup`, `scutil`, and `route`. Requires no additional tools.

**Linux** — uses `ip`, `/sys/class/net`, and `curl`. SSID detection tries `iwgetid`, `nmcli`, then `iw` (whichever is available). DNS reads from `resolvectl` with `/etc/resolv.conf` as fallback.

**Windows** — PowerShell 5.1+ (`helpnet.ps1`) with a `helpnet.bat` launcher so you don't have to invoke PowerShell manually. Uses `Get-NetAdapter`, `Get-NetRoute`, `Get-DnsClientServerAddress`, and `Invoke-RestMethod` — no external tools required.

## Requirements

| Platform | Requirements |
|----------|-------------|
| macOS | macOS 12+, no extras |
| Linux | `curl`; one of `iwgetid`, `nmcli`, or `iw` for SSID |
| Windows | Windows 10+, PowerShell 5.1+ |
