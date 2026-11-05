# Failover Testing

## Test 1 — Normal operation

1. Check that the VIP is owned by `pi-node-1`.
2. Run a DNS query against the VIP.
3. Confirm that Pi-hole responds.

Expected result: DNS resolution works through the active node.

## Test 2 — Primary node offline

1. Stop Pi-hole or shut down `pi-node-1`.
2. Check which node owns the VIP.
3. Run a DNS query against the VIP again.

Expected result: The VIP moves to `pi-node-2`; DNS resolution continues.

## Test 3 — Primary node returns

1. Start `pi-node-1` again.
2. Observe VIP ownership.
3. Run DNS queries again.

Expected result: Depending on the configured priority and preemption settings, the VIP returns to the primary node or remains on the backup until the next failover event.

## Results

| Test | Result | Notes |
|---|---|---|
| Normal operation | Passed | DNS query succeeded via VIP |
| Primary failure | Passed | VIP moved to backup node |
| Primary recovery | Passed | Service remained available |
