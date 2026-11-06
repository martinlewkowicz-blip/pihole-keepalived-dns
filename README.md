# Pi-hole + Keepalived High-Availability DNS

This repository provides a complete, production-oriented setup for running **two Pi-hole DNS servers** behind a FRITZ!Box (or any router that can distribute only one local DNS server through DHCP).

A virtual IP address (VIP) is shared between both Pi-hole nodes using **Keepalived/VRRP**. Clients always use the VIP. If the active node fails, the standby node takes over the VIP automatically.

```text
LAN clients
    |
    | DNS query to VIP (for example 192.168.178.53)
    v
FRITZ!Box DHCP
    |
    +-- Pi-hole Node 1  192.168.178.10
    |
    +-- Pi-hole Node 2  192.168.178.11
```

## What this setup provides

- A single DNS IP address for all LAN clients.
- Automatic failover if one Pi-hole node or its network interface fails.
- Optional active DNS health checking, so failover also occurs when Pi-hole is running but DNS is not answering.
- Aggressive Pi-hole blocklists, including HaGeZi Ultimate and Threat Intelligence Feeds.
- Firewall rules that expose only DNS ports on the VIP.
- Clear separation between the VIP and each node’s real IP address.

## Important design decision

The VIP is intended **only for DNS**.

Do not expose SSH, the Pi-hole web interface, Kubernetes NodePorts, or other services through the VIP unless those services are intentionally made highly available on both nodes.

This repository includes `nftables` rules that allow only TCP/UDP port 53 on the VIP and drop every other connection to it.

## Requirements

- Two Raspberry Pi devices, mini PCs, VMs, or other always-on Linux hosts.
- Raspberry Pi OS Lite, Debian, Ubuntu, or another systemd-based Linux distribution.
- Pi-hole v6 or newer on both nodes.
- Both nodes in the same Layer 2 network/VLAN.
- A free static IP address for each node.
- One additional unused IP address for the shared VIP.
- Router access to configure DHCP and DNS settings.

## Example addressing

Replace these values throughout the repository:

| Role | Example IP |
|---|---|
| FRITZ!Box / router | `192.168.178.1` |
| Pi-hole Node 1 | `192.168.178.10` |
| Pi-hole Node 2 | `192.168.178.11` |
| Shared DNS VIP | `192.168.178.53` |

Use IP addresses that are outside your router’s automatic DHCP range, or reserve them explicitly in the router.

## Quick start

1. Install Pi-hole on both nodes.
2. Install and configure Keepalived using the examples in `config/keepalived/`.
3. Install the DNS health-check script from `scripts/`.
4. Apply the optional firewall rules from `docs/setup.md`.
5. Configure aggressive blocklists using `config/pihole/pihole-settings-example.md`.
6. Set the VIP as the local DNS server in your router.
7. Test failover using `docs/failover-test.md`.

## FRITZ!Box note

Most FRITZ!Box models allow only **one local DNS server** to be distributed through DHCP:

```text
Heimnetz -> Netzwerk -> Netzwerkeinstellungen
-> IP-Adressen -> IPv4-Konfiguration -> Heimnetz
-> Lokaler DNS-Server
```

Enter only the VIP there, for example:

```text
192.168.178.53
```

Do not enter the individual Pi-hole node IPs in this field.

## Configuration

This repository contains example values only.

Do not commit real IP addresses, hostnames, MAC addresses, passwords,
API tokens, or VRRP authentication keys to a public repository.

Use a private Ansible inventory and Ansible Vault for environment-specific
values.

## Security notes

- Keep SSH and the Pi-hole web interface on the real node IPs.
- Restrict the Pi-hole web interface to your management network or trusted devices.
- Use strong passwords for SSH and the Pi-hole admin interface.
- Keep both Pi-hole installations updated, but update one node at a time.
- Do not use the same VRRP `virtual_router_id` as another Keepalived instance in the same VLAN.

## License

MIT License. See [LICENSE](LICENSE).
