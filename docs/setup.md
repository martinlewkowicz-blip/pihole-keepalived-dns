# Setup guide

This guide configures two Pi-hole nodes with a shared virtual IP address.

The examples use these addresses:

| Role | Example IP |
|---|---|
| Router | `192.168.178.1` |
| Pi-hole Node 1 | `192.168.178.10` |
| Pi-hole Node 2 | `192.168.178.11` |
| Shared DNS VIP | `192.168.178.53` |
| Network interface | `eth0` |

Change every IP address and interface name to match your network.

## 1. Prepare both nodes

Update both systems:

```bash
sudo apt update
sudo apt full-upgrade -y
sudo apt install -y curl git dnsutils keepalived nftables
sudo reboot
```

After reboot, connect again:

```bash
ssh user@192.168.178.10
ssh user@192.168.178.11
```

## 2. Install Pi-hole

Run this on **both** nodes:

```bash
curl -sSL https://install.pi-hole.net | bash
```

During installation:

- Select your real Ethernet interface, usually `eth0`.
- Select upstream DNS servers such as Cloudflare or Quad9.
- Enable the Pi-hole web interface.
- Enable query logging initially.
- Complete the installation and save the generated web-interface password.

Verify Pi-hole:

```bash
pihole status
dig @127.0.0.1 example.com
```

## 3. Reserve IP addresses

In your router, create DHCP reservations for both Pi-hole nodes:

```text
Pi-hole Node 1: 192.168.178.10
Pi-hole Node 2: 192.168.178.11
```

Do **not** create a DHCP reservation for the VIP. The VIP is managed by Keepalived.

Make sure the VIP is unused and outside the router’s automatic DHCP pool, or explicitly excluded from DHCP.

## 4. Install the DNS health check

On **both** nodes:

```bash
sudo install -m 750 scripts/health-check.example.sh /usr/local/sbin/pihole-dns-health-check.sh
```

Test it manually:

```bash
sudo /usr/local/sbin/pihole-dns-health-check.sh
echo $?
```

Expected result:

```text
0
```

If Pi-hole is not answering, the script returns a non-zero exit code.

## 5. Configure Keepalived

Copy the matching example configuration.

On Node 1:

```bash
sudo cp config/keepalived/pihole-node-1.keepalived.conf.example /etc/keepalived/keepalived.conf
```

On Node 2:

```bash
sudo cp config/keepalived/pihole-node-2.keepalived.conf.example /etc/keepalived/keepalived.conf
```

Edit both files:

```bash
sudo nano /etc/keepalived/keepalived.conf
```

Change:

- `eth0` to your real interface name.
- `192.168.178.53/24` to your VIP.
- `ChangeThisVRRPKey` to a private string.
- `virtual_router_id` if `51` is already used in your VLAN.

Find your interface name with:

```bash
ip -brief address show
```

Enable Keepalived:

```bash
sudo systemctl enable --now keepalived
sudo systemctl status keepalived
```

Check which node owns the VIP:

```bash
ip addr show dev eth0 | grep 192.168.178.53
```

## 6. Restrict the VIP to DNS

Create the firewall directory if needed:

```bash
sudo mkdir -p /etc/nftables.d
```

Create `/etc/nftables.d/pihole-vip.nft` on **both** nodes:

```bash
sudo tee /etc/nftables.d/pihole-vip.nft >/dev/null <<'EOF'
table inet pihole_vip {
    chain input {
        type filter hook input priority filter + 10; policy accept;

        ip daddr 192.168.178.53 tcp dport 53 accept
        ip daddr 192.168.178.53 udp dport 53 accept

        ip daddr 192.168.178.53 drop
    }
}
EOF
```

Apply it:

```bash
sudo nft -f /etc/nftables.d/pihole-vip.nft
```

Make it persistent:

```bash
if ! grep -q '/etc/nftables.d/\*.nft' /etc/nftables.conf; then
  echo 'include "/etc/nftables.d/*.nft"' | sudo tee -a /etc/nftables.conf
fi

sudo systemctl enable --now nftables
```

Verify:

```bash
sudo nft list ruleset
```

## 7. Configure aggressive blocklists

Run the commands from:

```text
config/pihole/pihole-settings-example.md
```

on **both** Pi-hole nodes.

The recommended minimum aggressive configuration is:

```bash
sudo pihole-FTL sqlite3 /etc/pihole/gravity.db <<'SQL'
INSERT OR IGNORE INTO adlist (address, enabled, comment) VALUES
('https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/ultimate.txt', 1, 'HaGeZi Ultimate - maximum blocking'),
('https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/tif.txt', 1, 'HaGeZi Threat Intelligence Feeds'),
('https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/spam-tlds.txt', 1, 'HaGeZi Most Abused TLDs');
SQL

sudo pihole -g
```

For maximum coverage, also add OISD Big, StevenBlack, URLhaus and Phishing Army as shown in `config/pihole/pihole-settings-example.md`.

## 8. Configure the router

In the FRITZ!Box:

```text
Heimnetz -> Netzwerk -> Netzwerkeinstellungen
-> IP-Adressen -> IPv4-Konfiguration -> Heimnetz
-> Lokaler DNS-Server
```

Enter:

```text
192.168.178.53
```

Save the configuration.

Renew DHCP leases on clients, or reboot them, so they receive the new DNS server.

## 9. Verify the complete setup

From a LAN client:

```bash
nslookup example.com 192.168.178.53
dig @192.168.178.53 example.com
```

From either Pi-hole node:

```bash
dig @192.168.178.53 example.com
```

Check that the VIP is owned by Node 1:

```bash
ssh user@192.168.178.10 'ip addr show dev eth0 | grep 192.168.178.53'
```

Then follow `docs/failover-test.md`.
