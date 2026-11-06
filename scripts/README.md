# Scripts

## health-check.example.sh

This script checks whether the local Pi-hole DNS service is actually answering DNS queries.

Keepalived uses the script’s exit code:

| Exit code | Meaning |
|---|---|
| `0` | DNS is healthy |
| Non-zero | DNS is unhealthy; Keepalived may fail over |

## Installation

On **both** Pi-hole nodes:

```bash
sudo install -m 750 scripts/health-check.example.sh /usr/local/sbin/pihole-dns-health-check.sh
```

Install the required tool:

```bash
sudo apt install -y dnsutils
```

Test manually:

```bash
sudo /usr/local/sbin/pihole-dns-health-check.sh
echo $?
```

Expected output:

```text
0
```

## How it works

The script performs two checks:

1. It queries the local Pi-hole instance at `127.0.0.1` using `dig`.
2. It verifies that the `pihole-FTL` systemd service is active.

This detects cases where the host and network are online, but Pi-hole itself is not serving DNS correctly.

## Keepalived integration

The provided Keepalived examples reference this path:

```conf
script "/usr/local/sbin/pihole-dns-health-check.sh"
```

The relevant Keepalived block is:

```conf
vrrp_script check_pihole_dns {
    script "/usr/local/sbin/pihole-dns-health-check.sh"
    interval 5
    timeout 3
    fall 2
    rise 2
}
```

With these values:

- The check runs every 5 seconds.
- Two consecutive failures mark the node unhealthy.
- Two consecutive successful checks mark it healthy again.
- Maximum detection time is approximately 10 seconds plus VRRP failover time.

## Customization

Change the test domain:

```bash
sudo systemctl edit keepalived
```

Or modify the script directly:

```bash
sudo nano /usr/local/sbin/pihole-dns-health-check.sh
```

To use a different domain without editing the script:

```bash
PIHOLE_HEALTH_TEST_DOMAIN=cloudflare.com \
  sudo -E /usr/local/sbin/pihole-dns-health-check.sh
```
