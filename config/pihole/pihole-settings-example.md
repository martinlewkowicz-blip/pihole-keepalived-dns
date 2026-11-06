# Pi-hole settings

This document describes a deliberately aggressive Pi-hole configuration for a secondary DNS server.

Use it when availability and maximum blocking are more important than compatibility with every service.

## Recommended blocklists

The following configuration uses HaGeZi Ultimate as the main list, plus threat-intelligence and malicious-domain feeds.

### Add blocklists

Pi-hole v6 stores adlists in `/etc/pihole/gravity.db`.

Run this on **each Pi-hole node**:

```bash
sudo pihole-FTL sqlite3 /etc/pihole/gravity.db <<'SQL'
INSERT OR IGNORE INTO adlist (address, enabled, comment) VALUES
('https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/ultimate.txt', 1, 'HaGeZi Ultimate - maximum blocking'),
('https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/tif.txt', 1, 'HaGeZi Threat Intelligence Feeds'),
('https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/spam-tlds.txt', 1, 'HaGeZi Most Abused TLDs'),
('https://big.oisd.nl/', 1, 'OISD Big'),
('https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts', 1, 'StevenBlack Unified Hosts'),
('https://malware-filter.gitlab.io/malware-filter/urlhaus-filter-hosts.txt', 1, 'URLhaus Malware'),
('https://malware-filter.gitlab.io/malware-filter/phishing-filter-hosts.txt', 1, 'Phishing Army');
SQL
```

Update Gravity:

```bash
sudo pihole -g
```

Verify the configured lists:

```bash
pihole-FTL sqlite3 /etc/pihole/gravity.db \
  "SELECT id, enabled, address, comment FROM adlist ORDER BY id;"
```

## Important warning

This is intentionally aggressive.

HaGeZi Ultimate can block domains used by:

- Facebook, Instagram, WhatsApp and Messenger.
- Some Microsoft, Xbox and telemetry endpoints.
- Referral and affiliate links.
- Certain analytics, crash-reporting and marketing services.

Use the Pi-hole query log to identify false positives.

## Useful allowlist commands

Allow one exact domain:

```bash
sudo pihole allow example.com
sudo pihole -g
```

Allow a domain and all its subdomains:

```bash
sudo pihole allow --wild example.com
sudo pihole -g
```

Check whether a domain is blocked and by which list:

```bash
pihole -q example.com
```

## Upstream DNS recommendation

Use privacy-friendly resolvers with DNSSEC support.

Example upstream configuration:

```text
Primary:   1.1.1.1
Secondary: 1.0.0.1
```

Alternative:

```text
Primary:   9.9.9.9
Secondary: 149.112.112.112
```

Do not point Pi-hole at the router if the router itself uses Pi-hole as its DNS server. That can create a DNS loop.

## Router configuration

In the FRITZ!Box, enter only the shared VIP:

```text
Heimnetz -> Netzwerk -> Netzwerkeinstellungen
-> IP-Adressen -> IPv4-Konfiguration -> Heimnetz
-> Lokaler DNS-Server: 192.168.178.53
```

Replace `192.168.178.53` with your actual VIP.

## Keeping both nodes consistent

Both Pi-hole nodes should use:

- The same blocklists.
- The same allowlist entries.
- The same upstream DNS servers.
- The same DNS rebinding protection setting.
- The same conditional forwarding rules, if used.

Pi-hole does not automatically synchronize configuration between independent installations. You can either configure both nodes identically manually or use a configuration-sync solution.
