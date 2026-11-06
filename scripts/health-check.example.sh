#!/usr/bin/env bash
#
# Pi-hole DNS health check for Keepalived.
#
# Install as:
#   /usr/local/sbin/pihole-dns-health-check.sh
#
# Permissions:
#   sudo chmod 750 /usr/local/sbin/pihole-dns-health-check.sh
#
# Keepalived uses the exit code:
#   0 = healthy
#   non-zero = unhealthy
#
# Optional environment overrides:
#   PIHOLE_HEALTH_TEST_DOMAIN=example.com
#   PIHOLE_HEALTH_TIMEOUT=2

set -u

TEST_DOMAIN="${PIHOLE_HEALTH_TEST_DOMAIN:-example.com}"
TIMEOUT="${PIHOLE_HEALTH_TIMEOUT:-2}"

log() {
    printf '%s pihole-dns-health-check: %s\n' "$(date --iso-8601=seconds)" "$*" >&2
}

# Check that the local Pi-hole DNS service answers.
if ! command -v dig >/dev/null 2>&1; then
    log "ERROR: dig is not installed. Install dnsutils."
    exit 2
fi

if ! dig @127.0.0.1 "$TEST_DOMAIN" +time="$TIMEOUT" +tries=1 +short >/dev/null 2>&1; then
    log "ERROR: local Pi-hole DNS did not answer for ${TEST_DOMAIN}."
    exit 1
fi

# Optional second check: verify that Pi-hole FTL is active.
if systemctl is-active --quiet pihole-FTL; then
    log "OK: Pi-hole FTL is active and DNS is answering."
    exit 0
fi

log "ERROR: DNS answered, but pihole-FTL systemd service is not active."
exit 1
