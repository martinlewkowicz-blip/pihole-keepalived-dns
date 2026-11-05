# Keepalived Configuration Examples

This directory contains separate example configurations for the two Pi-hole nodes.

| File | Node | Role |
|---|---|---|
| [`pihole-node-1.keepalived.conf.example`](pihole-node-1.keepalived.conf.example) | Pi-hole node 1 | Primary / initial MASTER |
| [`pihole-node-2.keepalived.conf.example`](pihole-node-2.keepalived.conf.example) | Pi-hole node 2 | Backup / initial BACKUP |

## Important values

| Setting | Must match across nodes? | Purpose |
|---|---:|---|
| `virtual_router_id` | Yes | Identifies the VRRP group |
| `virtual_ipaddress` | Yes | Shared DNS address used by clients |
| `interface` | Usually yes | Network interface used for VRRP |
| `state` | No | Initial preferred role: `MASTER` or `BACKUP` |
| `priority` | No | Higher priority is preferred for the MASTER role |
| `router_id` | No | Unique identifier for each Keepalived node |


## Usage

Copy the matching example file to `/etc/keepalived/keepalived.conf` on the corresponding Raspberry Pi, adjust the placeholders, then validate and restart Keepalived according to your distribution’s service management setup.
