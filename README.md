# Highly Available DNS with Pi-hole and Keepalived

This project provides resilient DNS for a home network using two Raspberry Pi devices.

DNS (Domain Name System) translates names such as `example.com` into IP addresses. Pi-hole acts as a local DNS server and blocks requests to known advertising and tracking domains before they leave the network. This provides network-wide ad and tracker blocking without installing software on every device. [Pi-hole](https://pi-hole.net/)

To avoid a single point of failure, two Raspberry Pi devices run Pi-hole in parallel. Keepalived manages a shared virtual IP address (VIP). If the primary node fails, the VIP automatically moves to the backup node and DNS resolution continues.
