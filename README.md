# Huawei Network Automation Suite - Phase 1 MVP

🚀 **Vollautomatisierte Netzwerk-Management-Lösung für Huawei-Geräte**

## Überblick

Diese Phase 1 (MVP) Implementation des Huawei Network Automation Suite ermöglicht die vollautomatisierte Konfiguration und Verwaltung von 6 Huawei-Netzwerkgeräten:

- 2x Core Switches (CloudEngine S12700E)
- 2x Access Switches (CloudEngine S5700-28C-HI) 
- 1x Edge Router (NetEngine AR6300)
- 1x Management Switch (CloudEngine S5720-12TP-PWR-LI)

## 🎯 Phase 1 Features

✅ **SSH Key Authentication** - Sichere schlüsselbasierte Authentifizierung  
✅ **Template-basierte Konfiguration** - Jinja2 Templates für alle Gerätetypen  
✅ **Sequentielle Deployment** - Intelligente Reihenfolge der Gerätekonfiguration  
✅ **Basic VLAN Management** - VLANs 10, 100-103, 999  
✅ **STP/RSTP Implementation** - Spanning Tree Protocol  
✅ **OSPF Single Area** - Area 0 Routing  
✅ **Retry-Mechanismen** - Robuste Error Handling  
✅ **Configuration Validation** - Template und Syntax Checks  

## 📁 Projektstruktur

```
src/automation/huawei/
├── scripts/core/
│   ├── device_manager.py          # SSH-Verbindungen und Device Operations
│   ├── template_engine.py         # Jinja2 Template Processing
│   └── deployment_orchestrator.py # Deployment Orchestration
├── inventory/
│   └── inventory.yaml             # Geräte-Inventar und Konfiguration
├── templates/
│   ├── core_switch.j2             # Core Switch Template
│   ├── access_switch.j2           # Access Switch Template
│   ├── edge_router.j2             # Edge Router Template
│   └── mgmt_switch.j2             # Management Switch Template
└── configs/                       # Generierte Konfigurationen
```

## 🚀 Schnellstart

### 1. Environment Setup

```bash
# Environment Variablen setzen
export ADMIN_PASSWORD_HASH="your_admin_password_hash"
export CONSOLE_PASSWORD_HASH="your_console_password_hash"
export SNMP_COMMUNITY="your_snmp_community"
```

### 2. SSH Keys vorbereiten

```bash
# SSH Key generieren (falls nicht vorhanden)
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa

# Public Key auf Geräte kopieren (manuell oder via existing access)
```

### 3. Validierung

```bash
# Templates und Prerequisites validieren
python src/main.py validate

# Gerätekonnektivität testen
python src/main.py test
```

### 4. Configuration Generation

```bash
# Konfigurationen für alle Geräte generieren
python src/main.py generate

# Für spezifisches Gerät mit Anzeige
python src/main.py generate --device core-switch-1 --show
```

### 5. Deployment

```bash
# Dry Run (Test ohne Änderungen)
python src/main.py deploy --dry-run

# Vollständiges Deployment
python src/main.py deploy

# Einzelnes Gerät deployen
python src/main.py deploy --device mgmt-switch
```

## 📋 Verfügbare Kommandos

### Validation
```bash
python src/main.py validate
```
Überprüft Templates, Prerequisites und Geräteerreichbarkeit.

### Info
```bash
python src/main.py info
```
Zeigt Inventar, Deployment-Sequenz und VLAN-Informationen.

### Test
```bash
python src/main.py test  
```
Testet SSH-Konnektivität zu allen Geräten.

### Generate
```bash
python src/main.py generate [--device DEVICE] [--show]
```
Generiert Konfigurationsdateien aus Templates.

### Deploy
```bash
python src/main.py deploy [--device DEVICE] [--dry-run] [--continue-on-error]
```
Deployed Konfigurationen auf Geräte.

## 🔧 Konfiguration

### Inventory Anpassung

Bearbeite `src/automation/huawei/inventory/inventory.yaml`:

```yaml
devices:
  - name: core-switch-1
    type: core_switch
    host: 192.168.10.1
    hostname: "CORE-SW-01"
    username: "admin"
    ssh_key: "~/.ssh/id_rsa"
    # ... weitere Konfiguration
```

### Template Anpassung

Templates befinden sich in `src/automation/huawei/templates/`:
- Jinja2 Syntax
- Device-spezifische Variablen aus Inventory
- Conditional Logic unterstützt

## 🧪 Testing

### Unit Tests ausführen
```bash
python -m pytest tests/ -v
```

### Spezifische Tests
```bash
python -m pytest tests/test_device_manager.py -v
python -m pytest tests/test_template_engine.py -v
```

## 📊 Deployment Sequenz (Phase 1)

1. **Management Switch** - Out-of-Band Management Setup
2. **Core Switch 1** - Primary Core Infrastructure  
3. **Core Switch 2** - Secondary Core Infrastructure
4. **Access Switch 1** - Marketing & Sales Access
5. **Access Switch 2** - IT & Finance Access
6. **Edge Router** - WAN Connectivity & Routing

## 🔐 Sicherheit

- **SSH Key Authentication** - Keine Passwörter im Code
- **Environment Variables** - Sensible Daten in ENV vars
- **Ansible Vault** - Verschlüsselte Credential Storage (für Phase 2)
- **Audit Logging** - Alle Operationen werden geloggt

## 🐛 Troubleshooting

### Häufige Probleme

**Connection Timeout:**
```bash
# SSH Konnektivität prüfen
python src/main.py test
```

**Template Fehler:**
```bash
# Template Validation
python src/main.py validate
```

**Permission Denied:**
```bash
# SSH Key Permissions prüfen
chmod 600 ~/.ssh/id_rsa
```

### Logging

Logs werden in `huawei_automation.log` gespeichert:
```bash
tail -f huawei_automation.log
```

## 🔄 Phase 2 Ausblick

🚀 **Geplante Erweiterungen:**
- Multi-Threading für parallele Deployments
- Advanced Error Handling Patterns
- Configuration Drift Detection
- Self-Healing Capabilities
- BGP & Multi-Area OSPF
- Zero-Touch Provisioning
- Chaos Engineering Tests

## 📞 Support

Bei Problemen oder Fragen:
1. Logs überprüfen (`huawei_automation.log`)
2. Validation ausführen (`python src/main.py validate`)
3. Test-Konnektivität prüfen (`python src/main.py test`)

---

**Phase 1 Status: ✅ IMPLEMENTIERT**  
**Nächste Phase: 🚀 Enterprise Features (Phase 2)**
