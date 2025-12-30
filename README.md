# Network Diagnostic Script

A lightweight Bash-based network diagnostic tool for SRE operations.

## Purpose
Automated network health checks for connectivity, DNS resolution, port availability, and TCP connection analysis on Linux systems.

## Features (In Progress)
- [x] Connectivity testing (ICMP ping)
- [ ] DNS resolution validation
- [ ] Port availability checks
- [ ] TCP connection state analysis
- [ ] Service health monitoring

## Requirements
- Bash 4.0+
- Standard Linux tools: `ping`, `dig`, `ss`, `timeout`

## Usage
```bash
chmod +x netdiag_sre.sh
./netdiag_sre.sh
```

## Development Timeline
**Week 1:** Core functionality
- Day 1: Connectivity + DNS checks
- Day 2-3: Port checking + TCP analysis
- Day 4-5: Service monitoring + polish
- Day 6-7: Testing + documentation

## Learning Resources
- *How Linux Works* by Brian Ward
- *The Linux Programming Interface* by Michael Kerrisk
- *Computer Networking: A Top-Down Approach* by Kurose & Ross

## Author
Ibrahim

Built as part of networking fundamentals deep-dive and SRE learning journey.

## License
MIT
