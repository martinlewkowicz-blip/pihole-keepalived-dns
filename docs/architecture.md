# Architecture

## Goal

Provide highly available DNS for a home network using two Raspberry Pi devices and Pi-hole.

## Design

Both Raspberry Pi devices run an independent Pi-hole instance. Keepalived assigns a virtual IP address to the currently active node.

Clients use only the virtual IP as their DNS server. If the active node fails, Keepalived moves the VIP to the backup node.

## Network Overview

```text
Clients
   |
   | DNS query to VIP
   v
Virtual IP (VIP)
   |
   +-- pi-node-1: Pi-hole + Keepalived (primary)
   |
   +-- pi-node-2: Pi-hole + Keepalived (backup)
```

## Failover Principle

- Keepalived uses VRRP to coordinate VIP ownership.
- The primary node normally owns the VIP.
- If the primary becomes unreachable, the backup takes over the VIP.
- Both Pi-hole instances should stay synchronized or use a common upstream/configuration strategy.

## Notes

- The exact IP addresses, interfaces and priorities are environment-specific.
- Use placeholder values in all committed configuration examples.
