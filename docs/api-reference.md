# 📚 Huawei Network Automation Suite - API Reference

## 📋 Überblick

Diese API Reference dokumentiert alle verfügbaren Klassen, Methoden und Datenstrukturen der Phase 1 MVP. Die API ist modular aufgebaut und bietet eine klare Trennung zwischen Device Management, Template Processing und Deployment Orchestration.

## 🏗️ Core Module Architecture

### **Module Hierarchy**
```
src.automation.huawei.scripts.core/
├── device_manager.py     -> DeviceManager Class
├── template_engine.py    -> TemplateEngine Class  
└── deployment_orchestrator.py -> DeploymentOrchestrator Class
```

---

## 🔧 DeviceManager API

### **Class: DeviceManager**

**Location**: `src/automation/huawei/scripts/core/device_manager.py`

**Purpose**: SSH-basierte Geräteverwaltung und -kommunikation für Huawei Netzwerkgeräte.

#### **Constructor**

```python
DeviceManager()
```

**Description**: Initialisiert den DeviceManager mit Standard-Konfiguration.

**Returns**: `DeviceManager` - Instanz für Device-Operationen

**Example**:
```python
from src.automation.huawei.scripts.core.device_manager import DeviceManager

dm = DeviceManager()
```

#### **Methods**

##### **connect(device_name: str, device_ip: str) -> bool**

**Description**: Stellt SSH-Verbindung zu einem Huawei Netzwerkgerät her.

**Parameters**:
- `device_name` (str): Eindeutiger Name des Geräts (z.B. "core-sw-01")
- `device_ip` (str): IP-Adresse des Geräts (z.B. "192.168.20.10")

**Returns**: 
- `bool`: `True` bei erfolgreicher Verbindung, `False` bei Fehler

**Raises**:
- `ConnectionError`: Bei SSH-Verbindungsfehlern
- `AuthenticationError`: Bei Authentifizierungsfehlern
- `TimeoutError`: Bei Verbindungs-Timeouts

**Example**:
```python
dm = DeviceManager()
success = dm.connect("core-sw-01", "192.168.20.10")
if success:
    print("✅ Verbindung erfolgreich")
else:
    print("❌ Verbindung fehlgeschlagen")
```

##### **disconnect(device_name: str) -> bool**

**Description**: Trennt SSH-Verbindung zu einem spezifischen Gerät.

**Parameters**:
- `device_name` (str): Name des zu trennenden Geräts

**Returns**: 
- `bool`: `True` bei erfolgreicher Trennung, `False` bei Fehler

**Example**:
```python
dm.disconnect("core-sw-01")
```

##### **send_command(device_name: str, command: str) -> str**

**Description**: Sendet ein Kommando an ein verbundenes Gerät und gibt die Ausgabe zurück.

**Parameters**:
- `device_name` (str): Name des Zielgeräts
- `command` (str): Huawei CLI-Kommando (z.B. "display version")

**Returns**: 
- `str`: Kommando-Ausgabe vom Gerät

**Raises**:
- `DeviceNotConnectedError`: Wenn Gerät nicht verbunden
- `CommandExecutionError`: Bei Kommando-Ausführungsfehlern

**Example**:
```python
output = dm.send_command("core-sw-01", "display version")
print(f"Device Info: {output}")
```

##### **deploy_config(device_name: str, configuration: str) -> bool**

**Description**: Deployed eine Konfiguration auf ein spezifisches Gerät.

**Parameters**:
- `device_name` (str): Name des Zielgeräts
- `configuration` (str): Huawei-konforme Konfiguration (multiline)

**Returns**: 
- `bool`: `True` bei erfolgreichem Deployment, `False` bei Fehler

**Example**:
```python
config = """
vlan 10
 description Management
interface Vlanif10
 ip address 192.168.10.1 255.255.255.0
"""
success = dm.deploy_config("mgmt-sw-01", config)
```

##### **get_connection_status() -> Dict[str, bool]**

**Description**: Gibt den Verbindungsstatus aller bekannten Geräte zurück.

**Returns**: 
- `Dict[str, bool]`: Dictionary mit Gerätename als Key und Verbindungsstatus als Value

**Example**:
```python
status = dm.get_connection_status()
for device, connected in status.items():
    print(f"{device}: {'✅' if connected else '❌'}")
```

#### **Configuration Attributes**

```python
@dataclass  
class ConnectionConfig:
    username: str = "admin"
    password: str = ""
    ssh_key_file: str = "~/.ssh/id_rsa"
    device_type: str = "huawei"
    timeout: int = 30
    max_retries: int = 3
    retry_delay: int = 2
```

---

## 📄 TemplateEngine API

### **Class: TemplateEngine**

**Location**: `src/automation/huawei/scripts/core/template_engine.py`

**Purpose**: Jinja2-basierte Template-Verarbeitung für Huawei Gerätekonfigurationen.

#### **Constructor**

```python
TemplateEngine(template_dir: str = "src/automation/huawei/templates")
```

**Parameters**:
- `template_dir` (str, optional): Pfad zum Template-Verzeichnis

**Example**:
```python
from src.automation.huawei.scripts.core.template_engine import TemplateEngine

te = TemplateEngine()
# oder mit custom path:
te = TemplateEngine("/path/to/custom/templates")
```

#### **Methods**

##### **list_templates() -> List[str]**

**Description**: Listet alle verfügbaren Jinja2-Templates im Template-Verzeichnis.

**Returns**: 
- `List[str]`: Liste der Template-Dateinamen

**Example**:
```python
te = TemplateEngine()
templates = te.list_templates()
print(f"Verfügbare Templates: {templates}")
# Output: ['management_switch.j2', 'core_switch.j2', 'access_switch.j2', 'edge_router.j2']
```

##### **validate_all_templates() -> Dict[str, Dict[str, Any]]**

**Description**: Validiert die Syntax aller verfügbaren Templates.

**Returns**: 
- `Dict[str, Dict[str, Any]]`: Validation-Ergebnisse pro Template

**Return Structure**:
```python
{
    "template_name.j2": {
        "valid": bool,           # True wenn Syntax korrekt
        "error": str or None,    # Fehlermeldung bei Syntax-Fehlern
        "variables": List[str],  # Liste erkannter Template-Variablen
        "size": int             # Template-Größe in Zeichen
    }
}
```

**Example**:
```python
te = TemplateEngine()
results = te.validate_all_templates()
for template, result in results.items():
    status = "✅ PASS" if result["valid"] else "❌ FAIL"
    print(f"{template}: {status}")
```

##### **render_template(template_name: str, variables: Dict) -> str**

**Description**: Rendert ein Template mit gegebenen Variablen zu einer Konfiguration.

**Parameters**:
- `template_name` (str): Name der Template-Datei (z.B. "core_switch.j2")
- `variables` (Dict): Template-Variablen als Key-Value Dictionary

**Returns**: 
- `str`: Gerenderte Huawei-Konfiguration

**Raises**:
- `TemplateNotFoundError`: Template-Datei nicht gefunden
- `TemplateRenderError`: Fehler beim Template-Rendering
- `UndefinedError`: Fehlende Template-Variablen

**Example**:
```python
te = TemplateEngine()
variables = {
    "hostname": "CORE-SW-01",
    "management_ip": "192.168.20.10",
    "vlans": {
        "10": {
            "name": "Management",
            "ip_address": "192.168.10.1",
            "subnet_mask": "255.255.255.0"
        }
    }
}
config = te.render_template("core_switch.j2", variables)
print(f"Generated config ({len(config)} chars):\n{config}")
```

##### **generate_config(device_type: str, device_vars: Dict) -> str**

**Description**: High-Level Methode zur Konfigurationsgenerierung basierend auf Device-Type.

**Parameters**:
- `device_type` (str): Gerätetyp ("management", "core", "access", "edge")
- `device_vars` (Dict): Device-spezifische Variablen

**Returns**: 
- `str`: Vollständige Huawei-Konfiguration

**Example**:
```python
te = TemplateEngine()
device_vars = {
    "hostname": "ACCESS-SW-01",
    "management_ip": "192.168.30.10",
    "access_ports": ["GigabitEthernet0/0/1", "GigabitEthernet0/0/2"],
    "vlans": {"30": {"name": "Data"}}
}
config = te.generate_config("access", device_vars)
```

#### **Custom Jinja2 Filters**

```python
# Verfügbare Custom Filters:
{{ ip_address | ipv4_network }}      # IP Network berechnen
{{ subnet_mask | wildcard_mask }}    # Wildcard Mask konvertieren  
{{ vlan_id | int }}                  # Integer Konvertierung
{{ interface | upper }}              # Uppercase Transformation
```

---

## 🎯 DeploymentOrchestrator API

### **Class: DeploymentOrchestrator**

**Location**: `src/automation/huawei/scripts/core/deployment_orchestrator.py`

**Purpose**: Koordiniert intelligente Deployment-Sequenzierung für Multiple Huawei Devices.

#### **Constructor**

```python
DeploymentOrchestrator()
```

**Example**:
```python
from src.automation.huawei.scripts.core.deployment_orchestrator import DeploymentOrchestrator

orchestrator = DeploymentOrchestrator()
```

#### **Methods**

##### **load_inventory(inventory_path: str) -> bool**

**Description**: Lädt Device-Inventory aus YAML-Datei.

**Parameters**:
- `inventory_path` (str): Pfad zur Inventory-YAML-Datei

**Returns**: 
- `bool`: `True` bei erfolgreichem Laden, `False` bei Fehlern

**Raises**:
- `FileNotFoundError`: Inventory-Datei nicht gefunden
- `YAMLParseError`: Fehler beim YAML-Parsing
- `InventoryValidationError`: Ungültige Inventory-Struktur

**Example**:
```python
orchestrator = DeploymentOrchestrator()
success = orchestrator.load_inventory("src/automation/huawei/inventory/devices.yaml")
if success:
    print("✅ Inventory erfolgreich geladen")
```

##### **validate_templates() -> bool**

**Description**: Validiert alle Templates für alle Geräte im Inventory.

**Returns**: 
- `bool`: `True` wenn alle Templates valid, `False` bei Fehlern

**Example**:
```python
orchestrator = DeploymentOrchestrator()
orchestrator.load_inventory("devices.yaml")
if orchestrator.validate_templates():
    print("✅ Alle Templates sind valid")
```

##### **get_devices() -> List[Dict[str, Any]]**

**Description**: Gibt Liste aller Geräte aus dem geladenen Inventory zurück.

**Returns**: 
- `List[Dict[str, Any]]`: Liste der Device-Definitionen

**Device Structure**:
```python
{
    "name": str,                 # Device Name
    "ip": str,                   # Management IP
    "role": str,                 # Device Role
    "device_type": str,          # netmiko Device Type
    "template": str,             # Template Filename
    "priority": int,             # Deployment Priority
    "credentials": {             # SSH Credentials
        "username": str,
        "password": str,
        "ssh_key_file": str
    },
    "variables": Dict[str, Any]  # Template Variables
}
```

**Example**:
```python
orchestrator = DeploymentOrchestrator()
orchestrator.load_inventory("devices.yaml")
devices = orchestrator.get_devices()
print(f"Loaded {len(devices)} devices:")
for device in devices:
    print(f"  ├── {device['name']} ({device['role']}) - Priority {device['priority']}")
```

##### **deploy_all_devices(dry_run: bool = True) -> DeploymentResult**

**Description**: Führt koordiniertes Deployment aller Geräte durch.

**Parameters**:
- `dry_run` (bool, optional): `True` für Simulation ohne echte Änderungen (default), `False` für Production Deployment

**Returns**: 
- `DeploymentResult`: Detaillierte Deployment-Ergebnisse

**Example**:
```python
orchestrator = DeploymentOrchestrator()
orchestrator.load_inventory("devices.yaml")

# Dry-Run (Safe)
result = orchestrator.deploy_all_devices(dry_run=True)
print(f"Deployment Status: {result.overall_success}")
print(f"Successful: {len(result.successful_devices)}")
print(f"Failed: {len(result.failed_devices)}")

# Production Deployment (Vorsicht!)
# result = orchestrator.deploy_all_devices(dry_run=False)
```

#### **Data Classes**

##### **DeploymentResult**

```python
@dataclass
class DeploymentResult:
    overall_success: bool                    # True wenn alle Devices erfolgreich
    successful_devices: List[str]            # Liste erfolgreicher Device-Namen
    failed_devices: List[str]                # Liste fehlgeschlagener Device-Namen
    deployment_time: float                   # Gesamte Deployment-Zeit in Sekunden
    total_config_lines: int                  # Summe aller generierten Config-Zeilen
    device_results: Dict[str, DeviceResult]  # Detaillierte Results pro Device
```

##### **DeviceResult**

```python
@dataclass
class DeviceResult:
    device_name: str          # Device Name
    success: bool             # Deployment Erfolg
    config_lines: int         # Anzahl Config-Zeilen
    execution_time: float     # Deployment-Zeit für dieses Device
    error_message: str        # Fehlermeldung (falls success=False)
    template_used: str        # Verwendetes Template
```

---

## 🗂️ Data Structures & Types

### **YAML Inventory Structure**

```yaml
# devices.yaml - Complete Structure
devices:
  - name: mgmt-sw-01                    # [REQUIRED] Unique device identifier
    ip: 192.168.10.10                   # [REQUIRED] Management IP address
    role: management                    # [REQUIRED] Device role (management|core|access|edge)
    device_type: huawei                 # [REQUIRED] netmiko device type
    template: management_switch.j2      # [REQUIRED] Jinja2 template filename
    priority: 1                         # [REQUIRED] Deployment priority (1=highest)
    
    credentials:                        # [REQUIRED] SSH Authentication
      username: admin                   # SSH username
      password: admin123                # SSH password (fallback)
      ssh_key_file: ~/.ssh/id_rsa      # SSH private key file
    
    variables:                          # [REQUIRED] Template-specific variables
      hostname: MGMT-SW-01              # Device hostname
      management_ip: 192.168.10.10      # Management IP
      mgmt_vlan: 10                     # Management VLAN ID
      features:                         # Feature list
        - snmp_monitoring
        - ssh_management
```

### **Template Variable Schema**

#### **Common Variables (alle Templates)**
```python
{
    # Base Configuration
    "hostname": str,                    # Device hostname (e.g., "CORE-SW-01")
    "management_ip": str,               # Management IP address
    "generation_time": str,             # Auto-generated timestamp
    "template_name": str,               # Source template filename
    
    # VLAN Configuration
    "vlans": {
        "vlan_id": {
            "name": str,                # VLAN name
            "description": str,         # VLAN description
            "ip_address": str,          # VLAN interface IP
            "subnet_mask": str          # Subnet mask
        }
    },
    
    # Feature Flags
    "features": [                       # List of enabled features
        "snmp_monitoring",
        "ssh_management",
        "stp_protection"
    ]
}
```

#### **Management Switch Variables**
```python
{
    "mgmt_vlan": int,                   # Management VLAN ID
    "snmp_community_ro": str,           # SNMP read-only community
    "snmp_community_rw": str,           # SNMP read-write community
    "ssh_timeout": int,                 # SSH session timeout
    "console_timeout": int              # Console timeout
}
```

#### **Core Switch Variables**
```python
{
    "vrrp_priority": int,               # VRRP priority (100-255)
    "ospf_area": str,                   # OSPF area (default: "0.0.0.0")
    "router_id": str,                   # OSPF router ID
    "trunk_ports": [str],               # List of trunk port interfaces
    "lacp_groups": {                    # LACP configuration
        "group_id": {
            "interfaces": [str],
            "mode": str                 # "active" or "passive"
        }
    }
}
```

#### **Access Switch Variables**
```python
{
    "access_ports": [str],              # List of access port interfaces
    "port_security": {                  # Port security settings
        "max_mac": int,                 # Maximum MAC addresses per port
        "aging_time": int,              # MAC aging time in minutes
        "violation_action": str         # "shutdown" or "restrict"
    },
    "default_vlan": int,                # Default access VLAN
    "voice_vlan": int                   # Voice VLAN ID
}
```

#### **Edge Router Variables**
```python
{
    "wan_interface": str,               # WAN interface name
    "lan_interface": str,               # LAN interface name
    "nat_pool": {                       # NAT configuration
        "start_ip": str,
        "end_ip": str,
        "netmask": str
    },
    "firewall_zones": {                 # Firewall zone configuration
        "trust": [str],                 # Trust zone interfaces
        "untrust": [str]                # Untrust zone interfaces
    },
    "static_routes": [                  # Static routing
        {
            "destination": str,
            "mask": str,
            "gateway": str
        }
    ]
}
```

---

## 🔧 Configuration Examples

### **Complete Device Setup Example**

```python
#!/usr/bin/env python3
"""
Complete Huawei Network Automation Example
Phase 1 MVP - 6 Device Deployment
"""

from src.automation.huawei.scripts.core.device_manager import DeviceManager
from src.automation.huawei.scripts.core.template_engine import TemplateEngine
from src.automation.huawei.scripts.core.deployment_orchestrator import DeploymentOrchestrator

def main():
    print("🚀 Huawei Network Automation Suite - Phase 1 MVP")
    
    # 1. Initialize Core Modules
    dm = DeviceManager()
    te = TemplateEngine()
    orchestrator = DeploymentOrchestrator()
    
    # 2. Validate Templates
    print("\n🔍 Template Validation:")
    validation_results = te.validate_all_templates()
    pass_count = sum(1 for result in validation_results.values() if result["valid"])
    total_count = len(validation_results)
    
    for template, result in validation_results.items():
        status = "✅ PASS" if result["valid"] else "❌ FAIL"
        print(f"  {template}: {status}")
    
    print(f"Template validation: {pass_count}/{total_count} PASS ({pass_count/total_count*100:.1f}% success rate)")
    
    # 3. Load Device Inventory
    print("\n📋 Loading Device Inventory:")
    inventory_loaded = orchestrator.load_inventory("src/automation/huawei/inventory/devices.yaml")
    
    if inventory_loaded:
        devices = orchestrator.get_devices()
        print(f"✅ Loaded {len(devices)} devices successfully")
        for device in devices:
            print(f"  ├── {device['name']} ({device['role']}) - Priority {device['priority']}")
    else:
        print("❌ Failed to load inventory")
        return
    
    # 4. Validate Templates for Inventory
    print("\n🎯 Template-Inventory Validation:")
    templates_valid = orchestrator.validate_templates()
    print(f"{'✅' if templates_valid else '❌'} Template-Inventory compatibility: {'OK' if templates_valid else 'FAILED'}")
    
    # 5. Generate Configuration Examples
    print("\n⚙️ Configuration Generation Examples:")
    total_config_chars = 0
    
    for device in devices[:2]:  # Show first 2 devices as examples
        try:
            config = te.render_template(device['template'], device['variables'])
            lines = len(config.split('\n'))
            chars = len(config)
            total_config_chars += chars
            print(f"  ├── {device['name']}: {lines} lines, {chars} characters")
        except Exception as e:
            print(f"  ├── {device['name']}: ❌ Error: {str(e)}")
    
    print(f"✅ Configuration generation working ({total_config_chars} characters generated)")
    
    # 6. Dry-Run Deployment
    print("\n🚀 Deployment Simulation (Dry-Run):")
    deployment_result = orchestrator.deploy_all_devices(dry_run=True)
    
    print(f"📊 Deployment Results Summary:")
    print(f"  ├── Overall Success: {'✅ YES' if deployment_result.overall_success else '❌ NO'}")
    print(f"  ├── Successful Devices: {len(deployment_result.successful_devices)}")
    print(f"  ├── Failed Devices: {len(deployment_result.failed_devices)}")
    print(f"  ├── Total Config Lines: {deployment_result.total_config_lines}")
    print(f"  └── Deployment Time: {deployment_result.deployment_time:.4f}s")
    
    # 7. System Status Summary
    print(f"\n✅ Phase 1 MVP Status: {'All systems operational' if deployment_result.overall_success else 'System errors detected'}")

if __name__ == "__main__":
    main()
```

### **Individual Module Usage Examples**

#### **DeviceManager Usage**
```python
# SSH Connection Management
dm = DeviceManager()

# Connect to multiple devices
devices = [
    ("mgmt-sw-01", "192.168.10.10"),
    ("core-sw-01", "192.168.20.10"),
    ("access-sw-01", "192.168.30.10")
]

for name, ip in devices:
    if dm.connect(name, ip):
        print(f"✅ {name} connected")
        version = dm.send_command(name, "display version")
        print(f"Version: {version[:100]}...")
        dm.disconnect(name)
    else:
        print(f"❌ {name} connection failed")
```

#### **TemplateEngine Usage**
```python
# Template Processing
te = TemplateEngine()

# Generate configuration for specific device
core_variables = {
    "hostname": "CORE-SW-01",
    "management_ip": "192.168.20.10",
    "vrrp_priority": 120,
    "ospf_area": "0.0.0.0",
    "vlans": {
        "10": {"name": "Management", "ip_address": "192.168.10.1"},
        "20": {"name": "Core", "ip_address": "192.168.20.1"}
    }
}

config = te.render_template("core_switch.j2", core_variables)
print(f"Generated {len(config.split())} lines of configuration")
```

#### **DeploymentOrchestrator Usage**
```python
# Full Deployment Orchestration
orchestrator = DeploymentOrchestrator()

# Load and validate
orchestrator.load_inventory("devices.yaml")
if orchestrator.validate_templates():
    
    # Dry-run first
    dry_result = orchestrator.deploy_all_devices(dry_run=True)
    print(f"Dry-run: {dry_result.overall_success}")
    
    # Production deployment (only if dry-run successful)
    if dry_result.overall_success:
        # Uncomment for production:
        # prod_result = orchestrator.deploy_all_devices(dry_run=False)
        # print(f"Production: {prod_result.overall_success}")
        pass
```

---

**📚 API Status: Complete & Production-Ready**  
**⚡ Performance: Optimized für Phase 1 MVP (6 Devices)**  
**🔐 Security: SSH Key Authentication + Error Handling**  
**📈 Extensibility: Ready für Phase 2 Enterprise APIs**
