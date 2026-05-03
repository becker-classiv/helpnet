# helpnet

Quick network overview for macOS and Linux. One command to see WiFi, Ethernet, gateway, DNS, internet reachability, public IP, and VPN status.

```
WiFi:     192.168.1.210  (MyNetwork)
Ethernet: 192.168.1.170  (en11 — USB 10/100/1G/2.5G LAN)
Gateway:  192.168.1.1
DNS:      192.168.1.1
Internet: reachable
Public:   203.0.113.42
Location: Denver, Colorado, US
VPN:      OFF
```

## Install

```bash
# macOS
curl -fsSL https://raw.githubusercontent.com/becker-classiv/helpnet/main/helpnet -o /usr/local/bin/helpnet
chmod +x /usr/local/bin/helpnet

# Linux
curl -fsSL https://raw.githubusercontent.com/becker-classiv/helpnet/main/helpnet-linux -o /usr/local/bin/helpnet
chmod +x /usr/local/bin/helpnet
```

Or clone and symlink:

```bash
git clone https://github.com/becker-classiv/helpnet.git
# macOS
ln -s "$PWD/helpnet/helpnet" /usr/local/bin/helpnet
# Linux
ln -s "$PWD/helpnet/helpnet-linux" /usr/local/bin/helpnet
```

## What it shows

| Field | Details |
|-------|---------|
| WiFi | IP address and SSID of the active wireless interface |
| Ethernet | IP, interface name, and adapter label — discovers dynamically, handles USB/Thunderbolt adapters at any `enN` number |
| Gateway | Default route gateway |
| DNS | Active nameservers |
| Internet | Reachable/unreachable based on a live HTTPS check |
| Public | Your external IP via [ipinfo.io](https://ipinfo.io) |
| Location | City, region, country from ipinfo.io |
| VPN | On/off — checks `utun` interfaces (macOS) or `tun/tap/wg/tailscale` interfaces (Linux), plus `scutil`/`nmcli` |

## Platform notes

**macOS** — uses `ipconfig`, `networksetup`, `scutil`, and `route`. Requires no additional tools.

**Linux** — uses `ip`, `/sys/class/net`, and `curl`. SSID detection tries `iwgetid`, `nmcli`, then `iw` (whichever is available). DNS reads from `resolvectl` with `/etc/resolv.conf` as fallback.

## Requirements

- `curl` (for public IP lookup)
- macOS 12+ or any modern Linux distro
- Linux SSID detection: one of `iwgetid`, `nmcli`, or `iw`
