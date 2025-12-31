# Network Diagnostic Script

A lightweight, production-grade Bash script for comprehensive network diagnostics and troubleshooting on Linux systems.

## 🎯 Purpose

Built for SRE and DevOps workflows, this tool provides automated network health checks across multiple layers of the networking stack. It consolidates essential diagnostic commands into a single, easy-to-use interface.

## ✨ Features

### Core Diagnostics

- **🌐 ICMP Connectivity Testing** - Verify host reachability using ping
- **📡 DNS Resolution** - Validate domain-to-IP resolution
- **🔌 Network Interfaces** - Display interface status, state, and IP assignments
- **🛣️ Routing Table** - Show default gateway and local network routes
- **🚪 Port Availability** - Test if specific ports are open, closed, or filtered
- **📊 TCP Connection States** - Analyze active connections (ESTABLISHED, TIME-WAIT, etc.)
- **👂 Listening Ports** - Enumerate all services listening on TCP ports

### Technical Highlights

- Zero external dependencies (uses standard Linux tools)
- Clean, colorized output with visual indicators (✓/✗/⏱)
- Modular function-based architecture
- Handles edge cases (timeouts, connection refused, link down)
- Works with or without sudo (graceful degradation)

## 📋 Requirements

- **OS**: Linux (Ubuntu 20.04+, Debian 11+, or similar)
- **Bash**: 4.0 or later
- **Tools**: `ping`, `dig`, `ss`, `ip`, `timeout` (all standard on modern Linux)

## 🚀 Installation
```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/Network_Diagnostic_Script.git
cd Network_Diagnostic_Script

# Make executable
chmod +x network_diagnoses.sh

# Run it
./network_diagnoses.sh
```

## 💻 Usage

### Basic Execution
```bash
./network_diagnoses.sh
```

### With Sudo (for complete process details)
```bash
sudo ./network_diagnoses.sh
```

### Sample Output
```
=== Network Diagnostics ===

✓ 8.8.8.8 is reachable (ICMP)

✓ google.com resolves to 142.251.12.113
✓ github.com resolves to 140.82.121.3

Network Interfaces:
  lo:        DOWN
  wlp2s0:    UP (192.168.1.100/24)
  eth0:      DOWN
  docker0:   DOWN

Routing Table:
  Default gateway: 192.168.1.1 via wlp2s0
  Local network: 192.168.1.0/24 dev wlp2s0
  Local network: 172.17.0.0/16 dev docker0 (link down)

✓ localhost:5432 is open (PostgreSQL)
✓ localhost:5000 is open (Flask)
✓ localhost:80 is open (nginx)

TCP Connection States:
  ESTAB:          16
  LISTEN:         8
  TIME-WAIT:      4
  CLOSE-WAIT:     1

Listening Ports:
  TCP 0.0.0.0:80          → nginx
  TCP 127.0.0.1:5432      → postgres
  TCP 0.0.0.0:5000        → gunicorn
  (Note: Run with 'sudo' for complete process details)

=== Complete ===
```

## 🏗️ Architecture

### Function Overview
```bash
check_connectivity()    # ICMP reachability test
check_dns()            # DNS resolution validation
check_interfaces()     # Network interface enumeration
check_routes()         # Routing table parsing
check_port()           # TCP port availability check
check_tcp_states()     # Connection state analysis
check_listening_ports() # Listening service enumeration
```

### Code Structure
```
network_diagnoses.sh
├── Function Definitions
│   ├── check_connectivity()  (~15 lines)
│   ├── check_dns()           (~15 lines)
│   ├── check_interfaces()    (~20 lines)
│   ├── check_routes()        (~25 lines)
│   ├── check_port()          (~30 lines)
│   ├── check_tcp_states()    (~20 lines)
│   └── check_listening_ports() (~20 lines)
└── main()                    (~30 lines)
```

**Total: ~175 lines of clean, well-documented Bash**

## 🔍 Technical Details

### Network Tools Used

| Tool | Purpose | Layer |
|------|---------|-------|
| `ping` | ICMP echo requests | Layer 3 (Network) |
| `dig` | DNS query resolution | Layer 7 (Application) |
| `ip addr` | Interface enumeration | Layer 2 (Data Link) |
| `ip route` | Routing table | Layer 3 (Network) |
| `/dev/tcp` | Port connectivity | Layer 4 (Transport) |
| `ss` | Socket statistics | Layer 4 (Transport) |

### Exit Codes

The script uses standard exit codes:
- `0` - Success
- `1` - General failure (connection refused, DNS failure, etc.)
- `124` - Timeout (from `timeout` command)

### Port Checking Logic

The `check_port()` function distinguishes between three states:
```bash
timeout 2 bash -c "</dev/tcp/host/port"
```

- **Exit 0**: Port is open (connection accepted)
- **Exit 1**: Port is closed (connection refused - RST received)
- **Exit 124**: Connection timed out (firewall or host unreachable)

## 🎓 Learning Resources

This script was built as part of a networking fundamentals deep-dive, drawing from:

- **How Linux Works (3rd Edition)** by Brian Ward - Chapter 9: Understanding Your Network
- **The Linux Programming Interface** by Michael Kerrisk - Chapter 59: Sockets
- **Computer Networking: A Top-Down Approach** by Kurose & Ross - TCP/IP Stack

## 🛠️ Development

### Built With

- Pure Bash (no Python, Perl, or external interpreters)
- Standard POSIX utilities
- Designed for maintainability and readability

### Testing

Tested on:
- ✅ Ubuntu 24.04 LTS
  
### Future Enhancements

Potential additions for v2.0:
- [ ] JSON output format (`--json`)
- [ ] Verbose mode (`--verbose`)
- [ ] Selective checks (`--dns-only`, `--ports-only`)
- [ ] IPv6 support
- [ ] Custom port lists
- [ ] Historical comparison
- [ ] Alert thresholds (e.g., too many TIME-WAIT)

## 📚 Use Cases

### SRE Operations
- Quick health checks during incidents
- Pre-deployment connectivity validation
- Post-deployment smoke tests

### Development
- Local environment troubleshooting
- Container networking debugging
- Service discovery validation

### System Administration
- Network configuration audit
- Security posture assessment
- Documentation of network state

## 🤝 Contributing

This is a learning project, but feedback is welcome!

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

MIT License - feel free to use, modify, and distribute.
---

*"Good network diagnostics prevent bad production incidents"*
