# Keepalived configuration

This directory contains example configurations for a two-node Pi-hole DNS failover setup.

## Files

| File | Purpose |
|---|---|
| `pihole-node-1.keepalived.conf.example` | Primary node configuration |
| `pihole-node-2.keepalived.conf.example` | Standby node configuration |

## Installation

On **both** nodes:

```bash
sudo apt update
sudo apt install -y keepalived
```

Copy the appropriate configuration:

```bash
# Node 1
sudo cp config/keepalived/pihole-node-1.keepalived.conf.example /etc/keepalived/keepalived.conf

# Node 2
sudo cp config/keepalived/pihole-node-2.keepalived.conf.example /etc/keepalived/keepalived.conf
```

Copy the health-check script:

```bash
sudo cp scripts/health-check.example.sh /usr/local/sbin/pihole-dns-health-check.sh
sudo chmod 750 /usr/local/sbin/pihole-dns-health-check.sh
```

Enable and start Keepalived:

```bash
sudo systemctl enable --now keepalived
```

## Values you must change

| Setting | Node 1 example | Node 2 example |
|---|---|---|
| `state` | `MASTER` | `BACKUP` |
| `priority` | `150` | `100` |
| `router_id` | `PIHOLE_NODE_1` | `PIHOLE_NODE_2` |
| `interface` | Your real interface | Your real interface |
| `virtual_router_id` | `51` | `51` |
| `auth_pass` | Same on both nodes | Same on both nodes |
| VIP | Same on both nodes | Same on both nodes |

## Find your network interface

```bash
ip -brief address show
```

Common values are:

- `eth0` on Raspberry Pi OS with Ethernet
- `end0` on some newer Raspberry Pi OS images
- `enp1s0`, `ens18`, or similar on x86 systems

## Verify Keepalived

On Node 1:

```bash
sudo systemctl status keepalived
sudo journalctl -u keepalived -f
ip addr show dev eth0
```

You should see the VIP assigned to the active node:

```text
inet 192.168.178.53/24 ...
```

On Node 2, the VIP should normally not be present while Node 1 is healthy.

## VRRP router ID

`virtual_router_id` must be:

- Identical on both Pi-hole nodes.
- Unique within the same Layer 2 broadcast domain/VLAN.
- Between `1` and `255`.

If another Keepalived installation already uses ID `51`, choose another value such as `52`, but use the same value on both Pi-hole nodes.

## Security

Change this line on both nodes:

```conf
auth_pass ChangeThisVRRPKey
```

Use the same value on both nodes. VRRP authentication is not strong encryption; it is mainly intended to prevent accidental participation by unrelated devices.
