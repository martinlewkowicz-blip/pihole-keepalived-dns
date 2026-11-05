# Setup

This documentation describes the general setup used in this lab.

## Prerequisites

- Two Raspberry Pi devices
- Raspberry Pi OS or another supported Linux distribution
- Pi-hole installed on both nodes
- Keepalived installed on both nodes
- Static IP addresses for both nodes
- One unused IP address in the local network for the VIP

## Node Layout

| Node | Hostname | IP address | Role |
|---|---|---|---|
| Node 1 | `pi-node-1` | `192.168.1.10` | Primary |
| Node 2 | `pi-node-2` | `192.168.1.11` | Backup |
| VIP | `pihole-vip` | `192.168.1.100` | Shared DNS address |

## Steps

1. Prepare both Raspberry Pi devices.
2. Install and configure Pi-hole on both nodes.
3. Install Keepalived on both nodes.
4. Configure VRRP priorities and the shared VIP.
5. Point client DNS settings to the VIP.
6. Test normal operation and failover.

## Configuration Examples

See [`config/keepalived/keepalived.conf.example`](../config/keepalived/keepalived.conf.example).

## Important

Replace all placeholder IP addresses, hostnames and interface names with values matching your own network.
