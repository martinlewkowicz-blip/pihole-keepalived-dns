# Failover testing

Test the setup before relying on it.

The examples assume:

- Node 1: `192.168.178.10`
- Node 2: `192.168.178.11`
- VIP: `192.168.178.53`
- Interface: `eth0`

## 1. Confirm the active node

On Node 1:

```bash
ip addr show dev eth0 | grep 192.168.178.53
```

Expected output:

```text
inet 192.168.178.53/24 ...
```

On Node 2:

```bash
ip addr show dev eth0 | grep 192.168.178.53
```

Expected result: no output while Node 1 is healthy.

## 2. Test DNS through the VIP

From a LAN client:

```bash
dig @192.168.178.53 example.com
```

Expected output includes an answer such as:

```text
;; ANSWER SECTION:
example.com. ... IN A ...
```

## 3. Test Keepalived failover

Stop Keepalived on Node 1:

```bash
ssh user@192.168.178.10
sudo systemctl stop keepalived
```

Immediately check Node 2:

```bash
ssh user@192.168.178.11
sudo journalctl -u keepalived -f
ip addr show dev eth0 | grep 192.168.178.53
```

Within a few seconds, Node 2 should acquire the VIP.

From a LAN client, run:

```bash
dig @192.168.178.53 example.com
```

DNS should continue working.

Restart Keepalived on Node 1:

```bash
sudo systemctl start keepalived
```

Node 1 should take the VIP back because it has the higher priority.

## 4. Test a full node failure

Power off Node 1:

```bash
ssh user@192.168.178.10
sudo poweroff
```

Check Node 2:

```bash
ip addr show dev eth0 | grep 192.168.178.53
```

Then test DNS from a client:

```bash
dig @192.168.178.53 example.com
```

Start Node 1 again and confirm that it becomes master after boot.

## 5. Test DNS health checking

This test verifies that Keepalived fails over when Pi-hole is broken but the node itself is still online.

On the active node, stop Pi-hole:

```bash
sudo systemctl stop pihole-FTL
```

Watch Keepalived:

```bash
sudo journalctl -u keepalived -f
```

After the configured `fall` count, the active node should release the VIP and the standby node should take over.

Test DNS:

```bash
dig @192.168.178.53 example.com
```

Then restore Pi-hole:

```bash
sudo systemctl start pihole-FTL
```

After the configured `rise` count, the original master should regain the VIP.

## 6. Test the firewall

From a LAN client, verify that DNS works:

```bash
dig @192.168.178.53 example.com
```

Verify that non-DNS access to the VIP is blocked:

```bash
curl -m 5 http://192.168.178.53/admin
ssh -o ConnectTimeout=5 user@192.168.178.53
```

Both connections should time out or be refused.

DNS must continue working.

## 7. Useful monitoring commands

On each node:

```bash
sudo systemctl status keepalived
sudo systemctl status pihole-FTL
sudo journalctl -u keepalived -n 100
sudo journalctl -u pihole-FTL -n 100
ip addr show
sudo nft list ruleset
pihole status
```

Check DNS response time:

```bash
dig @192.168.178.53 example.com | grep 'Query time'
```
