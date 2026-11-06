# Architecture

## Overview

This setup uses two independent Pi-hole installations and one shared virtual IP address.

```text
                 +----------------------+
                 |      FRITZ!Box       |
                 |  DHCP DNS = VIP      |
                 +----------+-----------+
                            |
                            | DNS queries to VIP
                            v
        +-------------------+-------------------+
        |                                       |
+-------v--------+                     +--------v-------+
| Pi-hole Node 1 |                     | Pi-hole Node 2 |
| 192.168.178.10 |                     | 192.168.178.11 |
| Keepalived     |<------------------->| Keepalived     |
| priority 150   |      VRRP           | priority 100   |
+----------------+                     +----------------+
        |
        +---------- Shared VIP: 192.168.178.53
```

## Components

### Pi-hole Node 1

- Primary Pi-hole DNS server.
- Keepalived state: `MASTER`.
- Higher VRRP priority, for example `150`.
- Normally owns the VIP.

### Pi-hole Node 2

- Standby Pi-hole DNS server.
- Keepalived state: `BACKUP`.
- Lower VRRP priority, for example `100`.
- Takes over the VIP when Node 1 fails.

### Virtual IP

The VIP is the only DNS address distributed to LAN clients.

Clients do not need to know the real IP addresses of either Pi-hole node.

## Failover behavior

Keepalived uses VRRP to elect the node that owns the VIP.

Normal operation:

```text
Client -> VIP -> Pi-hole Node 1
```

Node 1 failure:

```text
Client -> VIP -> Pi-hole Node 2
```

When Node 1 returns, it normally becomes master again because it has the higher priority.

## DNS health checking

Basic VRRP failover detects:

- A powered-off node.
- A disconnected network cable.
- A failed network interface.
- A lost Keepalived process.

It does not necessarily detect:

- Pi-hole running but not answering DNS.
- A container that is alive but unhealthy.
- DNS port conflicts.
- Firewall rules blocking port 53.

The included health-check script solves this by testing local DNS resolution. If DNS fails repeatedly, Keepalived reduces the node’s priority and allows the other node to take over.

## VIP scope

The VIP should be used only for DNS.

The recommended firewall policy is:

```text
Allow: TCP/53 and UDP/53 to VIP
Drop:  every other port on VIP
```

This prevents accidental exposure of SSH, Pi-hole’s web interface, Kubernetes NodePorts, or other services through the high-availability address.

## Why not simply enter two DNS servers?

Some operating systems and applications do not handle multiple DNS servers predictably. Many clients try the first DNS server and wait for a timeout before using the second one.

A VIP avoids this problem because clients always have exactly one DNS address. Failover happens at the network layer, before the client needs to choose another resolver.
