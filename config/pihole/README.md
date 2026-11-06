# Pi-hole configuration

This directory contains an example Pi-hole configuration for a high-availability DNS setup.

## Contents

| File | Purpose |
|---|---|
| `pihole-settings-example.md` | Aggressive blocklist and Pi-hole configuration examples |

## Installation

Install Pi-hole natively on both nodes:

```bash
curl -sSL https://install.pi-hole.net | bash
```

For a Raspberry Pi 2, use Raspberry Pi OS Lite 32-bit. Pi-hole requires at least 512 MB RAM and 2 GB of free storage.

## Recommended settings

- Install Pi-hole directly, without Docker, on low-memory devices.
- Use a wired Ethernet connection where possible.
- Assign a static IP or DHCP reservation to each node.
- Use the same upstream DNS servers on both nodes.
- Use the same blocklists and allowlists on both nodes.
- Enable query logging initially to identify false positives.
- Disable query logging later if SD-card wear or storage usage is a concern.

## Verify DNS

```bash
pihole status
dig @127.0.0.1 example.com
dig @192.168.178.53 example.com
```

Replace `192.168.178.53` with your actual VIP.

## Pi-hole web interface

Access each node directly through its real IP address:

```text
http://192.168.178.10/admin
http://192.168.178.11/admin
```

Do not rely on the VIP for administration unless you intentionally want the web interface to fail over too.
