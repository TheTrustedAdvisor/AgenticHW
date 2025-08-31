# Huawei Network Automation Suite - Requirements

## 1. Projektübersicht

### 1.1 Ziel
Entwicklung einer vollautomatisierten Netzwerk-Management-Lösung für 15 Huawei-Geräte mit SSH Key-basierter Authentifizierung, Template-basierter Konfiguration und umfassendem Testing.

### 1.2 Umfang
**Hardware-Inventar:**
- 2 Core Switches (CloudEngine S12700E)
- 2 Distribution Switches (CloudEngine S6720-30C-EI-24S)
- 4 Access Switches (CloudEngine S5700-28C-HI)
- 2 Edge Router (NetEngine AR6300)
- 2 VPN Gateways (NetEngine AR3200)
- 1 DMZ Firewall (USG6000E)
- 1 Internet Gateway (NetEngine AR1220C)
- 1 Management Switch (CloudEngine S5720-12TP-PWR-LI)

## 2. Technische Anforderungen

### 2.1 Entwicklungsumgebung
| Komponente | Version | Zweck |
|-----------|---------|-------|
| Python | 3.9+ | Hauptprogrammiersprache |
| napalm | 4.1.0 | Network Automation |
| netmiko | 4.2.0 | SSH-Verbindungen |
| Jinja2 | 3.1.2 | Template Engine |
| PyYAML | 6.0.1 | Konfigurationsdateien |
| pytest | 7.4.2 | Testing Framework |
| ansible | 8.2.0 | Deployment-Automation |

### 2.2 Projektstruktur
```
huawei-network-automation/
├── src/automation/huawei/
│   ├── scripts/core/          # Kern-Module
│   ├── inventory/             # Geräte-Inventar
│   ├── templates/             # Jinja2-Templates
│   └── configs/               # Generierte Konfigurationen
├── tests/                     # Test Suite
├── docs/                      # Dokumentation
└── requirements.txt           # Python Dependencies
```

## 3. Funktionale Anforderungen

### 3.1 Geräte-Management
**Device Manager:** SSH-basierte Verbindung zu allen Huawei-Geräten
- SSH Key Authentication (keine Passwörter)
- Automatische Geräteerkennung
- Connection Pooling für Performance
- Error Handling und Retry-Logik

### 3.2 Konfigurationsmanagement

**Core Switches (CloudEngine S12700E):**
| Feature | Konfiguration |
|---------|---------------|
| VLANs | 10, 100-103 (Abteilungen), 200-202 (Server), 500 (DMZ), 999 (Quarantine) |
| Inter-VLAN Routing | VLAN-Interfaces mit Gateway-IPs |
| STP | RSTP, Priority 4096, Root Primary |
| LACP | Eth-Trunk zwischen Core Switches |

**Access Switches (CloudEngine S5700-28C-HI):**
| Port-Range | VLAN | Features |
|------------|------|----------|
| 1-8 | 100 (Marketing) | PoE, Port Security, Max 2 MAC |
| 9-16 | 101 (Sales) | PoE, Port Security, Max 2 MAC |
| 17-20 | 200 (Web Server) | Access Mode |
| 21-24 | Uplinks | Trunk, alle VLANs |

**Edge Router (NetEngine AR6300):**
| Feature | Konfiguration |
|---------|---------------|
| Routing | OSPF Area 0, Static Default Route |
| Security | ACLs für Netzwerk-Segmentierung |
| QoS | Traffic Classes für Voice/Video/Data |
| NAT | Outbound NAT für interne Netzwerke |

**VPN Gateways (NetEngine AR3200):**
| VPN-Typ | Parameter |
|---------|-----------|
| IPSec Site-to-Site | IKE v2, AES-256, SHA2-256 |
| SSL VPN | Port 4433, Local Auth, Pool 192.168.100.0/24 |

**DMZ Firewall (USG6000E):**
| Security Zone | Trust Level | Interfaces |
|---------------|-------------|------------|
| Trust | 85 | Internal Network |
| DMZ | 50 | DMZ Network |
| Untrust | 5 | External Interface |

### 3.3 Template System
**Jinja2 Templates:** Ein Template pro Gerätetyp
- Variable Substitution aus YAML-Inventory
- Conditional Logic für verschiedene Konfigurationen
- Template Validation vor Deployment
- Versionskontrolle für alle Templates

### 3.4 Deployment Orchestration
**Deployment-Reihenfolge (zwingend einzuhalten):**
1. Management Switch
2. Core Switches 
3. Distribution Switches
4. Access Switches
5. Edge Router
6. DMZ Firewall
7. VPN Gateways
8. Internet Gateway

**Dependency Management:** Abhängigkeiten zwischen Geräten prüfen vor Deployment

## 4. Sicherheitsanforderungen

### 4.1 Authentifizierung
| Methode | Implementierung |
|---------|-----------------|
| SSH Keys | Private Keys in ~/.ssh/ mit 600 Permissions |
| Username | Über Environment Variables |
| Enable Password | Ansible Vault verschlüsselt |
| SNMP | Read-Only Communities, SNMPv3 |

### 4.2 Credential Management
- Alle sensiblen Daten in Ansible Vault
- Environment Variables für Runtime-Credentials
- Credential Rotation Strategy
- Audit Logging für alle Zugriffe

## 5. Testing-Anforderungen

### 5.1 Test-Framework
| Test-Typ | Technologie | Zweck |
|----------|-------------|-------|
| Unit Tests | pytest | Modulare Funktionalität |
| Integration Tests | ContainerLab | Geräte-Simulation |
| System Tests | TestInfra | End-to-End Validierung |

### 5.2 Test-Kategorien
**Connectivity Tests:** SSH-Verbindungen, Ping, SNMP-Verfügbarkeit
**Configuration Tests:** VLAN-Erstellung, Interface-Status, Routing-Tabellen
**Security Tests:** ACL-Funktionalität, Firewall-Regeln, VPN-Verbindungen
**Performance Tests:** Throughput, Latenz, CPU/Memory Usage

### 5.3 CI/CD Pipeline
| Stage | Prüfungen | Tools |
|-------|-----------|-------|
| Syntax Check | YAML/Jinja2 Validation | yamllint, ansible-lint |
| Unit Tests | Code Coverage | pytest, coverage |
| Integration Tests | ContainerLab Simulation | Docker, clab |
| Security Scan | Credential Security | git-secrets, vault |

## 6. Monitoring und Wartung

### 6.1 Network Monitoring
| Monitoring-Typ | Metriken | Alerting |
|----------------|----------|----------|
| Device Health | CPU, Memory, Temperature | Threshold > 80% |
| Interface Status | Link State, Utilization, Errors | Interface Down |
| Network Performance | Latency, Packet Loss | RTT > 50ms |
| Security Events | Failed Logins, ACL Hits | Sofortige Alerts |

### 6.2 Monitoring-Tools
**SNMP:** Performance Metrics von allen Geräten
**Syslog:** Centralized Event Logging
**Flow Analysis:** NetFlow/sFlow für Traffic Patterns
**Dashboard:** Grafana für Visualisierung

## 7. Dokumentation

### 7.1 Benutzer-Dokumentation
- Installation und Setup Guide
- Konfiguration und Deployment
- Troubleshooting Handbuch
- API Referenz

### 7.2 Technische Dokumentation
- Netzwerk-Architektur Diagramme
- Template-Referenz
- Security Best Practices
- Monitoring Setup

### 7.3 Automatisierte Dokumentation
**Tool:** Docusaurus für Website
**Features:** Auto-generated API Docs, Mermaid Diagramme
**Deployment:** GitHub Pages Integration

## 8. Implementierungs-Hinweise

### 8.1 Entwicklungsphase
1. Grundlegende Infrastruktur (Device Manager, Templates)
2. Core Funktionalität (Konfiguration, Deployment)
3. Testing Framework (Unit, Integration)
4. Monitoring und Alerting
5. Dokumentation und CI/CD

### 8.2 Best Practices
- CLI-Befehle sollen automatisch generiert werden, nicht hart codiert
- Alle Konfigurationen über Templates und Variablen
- Umfassende Fehlerbehandlung
- Detaillierte Logging für Debugging
- Backup-Strategien vor allen Änderungen

### 8.3 Error Handling
- Retry-Mechanismen für Netzwerk-Timeouts
- Rollback-Fähigkeiten bei fehlgeschlagenen Deployments
- Validation vor jeder Konfigurationsänderung
- Ausführliche Error-Messages für Troubleshooting
