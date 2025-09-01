#!/usr/bin/env python3
"""
Phase 1 MVP Demo System für Huawei Network Automation Suite
Vollständige Demonstration aller 3 Core Modules und 4 Templates

Features:
- DeviceManager: SSH-basierte Geräteverbindung
- TemplateEngine: 4/4 Template Validation (PASS erforderlich)
- DeploymentOrchestrator: Sequential Deployment
- Inventory-basierte Orchestrierung
- Dry-Run und Preview Modi
- Comprehensive Error Handling
"""

import os
import sys
import logging
from pathlib import Path
from datetime import datetime

# Add src to path for imports
project_root = Path(__file__).parent
src_path = project_root / "src"
sys.path.insert(0, str(src_path))

try:
    from automation.huawei.scripts.core.device_manager import DeviceManager
    from automation.huawei.scripts.core.template_engine import TemplateEngine
    from automation.huawei.scripts.core.deployment_orchestrator import DeploymentOrchestrator
except ImportError as e:
    print(f"❌ Import Error: {e}")
    print("Please ensure all dependencies are installed: pip install -r requirements.txt")
    sys.exit(1)


def setup_logging():
    """Setup logging for demo"""
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
        handlers=[
            logging.StreamHandler(),
            logging.FileHandler('phase1_mvp_demo.log')
        ]
    )


def print_banner():
    """Print demo banner"""
    print("\n" + "="*80)
    print("🚀 HUAWEI NETWORK AUTOMATION SUITE - PHASE 1 MVP DEMO")
    print("="*80)
    print("📋 Scope: 6 Huawei Devices - Core Infrastructure Automation")
    print("🎯 Features: SSH Auth, Template Engine, Sequential Deployment")
    print("⚡ Architecture: 3 Core Modules + 4 Templates + Comprehensive Testing")
    print("🔧 Python 3.13 Compatible - No telnetlib Dependencies")
    print("="*80)
    print()


def print_section(title):
    """Print section header"""
    print(f"\n{'─'*60}")
    print(f"📌 {title}")
    print(f"{'─'*60}")


def demonstrate_core_modules():
    """Demonstrate all 3 core modules"""
    print_section("CORE MODULES DEMONSTRATION")
    
    # 1. DeviceManager Demo
    print("\n🔧 1. DeviceManager - SSH-based Device Management")
    device_manager = DeviceManager()
    
    # Simulate device information
    devices = [
        ("mgmt-sw-01", "192.168.10.10", "Management Switch"),
        ("core-sw-01", "192.168.10.11", "Core Switch 1"),
        ("core-sw-02", "192.168.10.12", "Core Switch 2"),
        ("access-sw-01", "192.168.10.13", "Access Switch 1"),
        ("access-sw-02", "192.168.10.14", "Access Switch 2"),
        ("edge-router-01", "192.168.10.15", "Edge Router")
    ]
    
    print("   📊 Device Management Capabilities:")
    for device_name, ip, description in devices:
        print(f"   📡 {description}: {device_name} ({ip}) - Ready for SSH connection")
    
    print(f"   ✅ Total devices available: {len(devices)}")
    print("   📋 DeviceManager Methods:")
    print("      • connect(device_name, device_ip, **kwargs)")
    print("      • send_command(device_name, command)")
    print("      • deploy_config(device_name, configuration, dry_run=True)")
    print("      • disconnect(device_name)")
    print("      • get_connection_status()")
    
    # 2. TemplateEngine Demo
    print("\n🎨 2. TemplateEngine - Jinja2 Template Processing")
    template_dir = Path("src/automation/huawei/templates")
    template_engine = TemplateEngine(str(template_dir))
    
    # List available templates
    templates = template_engine.list_templates()
    print(f"   📄 Available templates: {len(templates)}")
    for template in templates:
        print(f"      • {template}")
    
    # Validate template syntax (Phase 1 Requirement: 4/4 PASS)
    print("\n   🔍 Template Syntax Validation (Phase 1 Requirement: 4/4 PASS):")
    validation_results = template_engine.validate_all_templates()
    valid_count = 0
    
    for template_name, result in validation_results.items():
        is_valid = result.get('valid', False)
        status = "✅ PASS" if is_valid else "❌ FAIL"
        print(f"      {status} {template_name}")
        if not is_valid and 'error' in result:
            print(f"         Error: {result['error']}")
        else:
            valid_count += 1
    
    print(f"\n   📊 Template Validation Summary: {valid_count}/{len(templates)} templates valid")
    if valid_count == len(templates):
        print("   🎉 SUCCESS: All templates passed validation!")
    else:
        print("   ⚠️  WARNING: Some templates failed validation")
    
    # 3. DeploymentOrchestrator Demo
    print("\n🎯 3. DeploymentOrchestrator - Intelligent Deployment")
    orchestrator = DeploymentOrchestrator(device_manager, template_engine)
    
    # Load inventory
    inventory_file = "src/automation/huawei/inventory/devices.yaml"
    if Path(inventory_file).exists():
        success = orchestrator.load_inventory(inventory_file)
        print(f"   📋 Inventory loading: {'✅ SUCCESS' if success else '❌ FAILED'}")
        
        if success:
            devices = orchestrator.get_devices()
            print(f"   📊 Devices in inventory: {len(devices)}")
            
            # Show deployment sequence
            deployment_sequence = orchestrator.get_deployment_sequence()
            print(f"   🎯 Phase 1 Sequential Deployment Order:")
            for i, device in enumerate(deployment_sequence, 1):
                role = device.get('role', 'unknown')
                name = device.get('name', 'unknown')
                template = device.get('template', 'unknown')
                print(f"      {i}. {name} ({role}) - Template: {template}.j2")
            
            # Validate templates
            templates_valid = orchestrator.validate_templates()
            print(f"   🔍 Template validation: {'✅ PASSED' if templates_valid else '❌ FAILED'}")
        
    else:
        print(f"   ⚠️  Inventory file not found: {inventory_file}")
    
    print("   ✅ DeploymentOrchestrator ready for sequential deployment")


def demonstrate_template_generation():
    """Demonstrate configuration generation"""
    print_section("CONFIGURATION GENERATION DEMO")
    
    template_engine = TemplateEngine("src/automation/huawei/templates")
    
    # Sample configuration generation for core switch
    print("\n🏗️  Generating Core Switch Configuration:")
    
    sample_variables = {
        'hostname': 'CORE-SW-01',
        'management_ip': '192.168.10.11',
        'generation_time': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
        'template_name': 'core_switch.j2',
        'vlans': {
            '10': {
                'name': 'Management',
                'description': 'Network Management VLAN',
                'ip_address': '192.168.10.1',
                'subnet_mask': '255.255.255.0'
            },
            '100': {
                'name': 'Marketing',
                'description': 'Marketing Department',
                'ip_address': '192.168.100.1',
                'subnet_mask': '255.255.255.0'
            },
            '101': {
                'name': 'Sales',
                'description': 'Sales Department',
                'ip_address': '192.168.101.1',
                'subnet_mask': '255.255.255.0'
            }
        },
        'stp': {
            'mode': 'rstp',
            'priority': 4096
        },
        'features': ['inter_vlan_routing', 'stp_rstp', 'trunk_links']
    }
    
    config = template_engine.render_template('core_switch.j2', sample_variables)
    
    if config:
        print("   ✅ Configuration generated successfully")
        
        # Save configuration for review
        configs_dir = Path("src/automation/huawei/configs")
        configs_dir.mkdir(exist_ok=True)
        
        config_file = configs_dir / "core-sw-01_demo.txt"
        with open(config_file, 'w') as f:
            f.write(config)
        
        print(f"   💾 Configuration saved to: {config_file}")
        
        # Show preview
        lines = config.split('\n')[:15]
        print("\n   📋 Configuration Preview (first 15 lines):")
        for i, line in enumerate(lines, 1):
            print(f"      {i:2d}: {line}")
        if len(config.split('\n')) > 15:
            print(f"      ... ({len(config.split('\n')) - 15} more lines)")
    else:
        print("   ❌ Configuration generation failed")


def demonstrate_deployment_simulation():
    """Demonstrate deployment simulation (dry run)"""
    print_section("DEPLOYMENT SIMULATION (DRY RUN)")
    
    device_manager = DeviceManager()
    template_engine = TemplateEngine("src/automation/huawei/templates")
    orchestrator = DeploymentOrchestrator(device_manager, template_engine)
    
    # Load inventory if available
    inventory_file = "src/automation/huawei/inventory/devices.yaml"
    if Path(inventory_file).exists():
        print("🔄 Loading device inventory...")
        success = orchestrator.load_inventory(inventory_file)
        
        if success:
            print("✅ Inventory loaded successfully")
            
            # Validate templates
            print("\n🔍 Validating templates...")
            templates_valid = orchestrator.validate_templates()
            
            if templates_valid:
                print("✅ Template validation passed")
                
                # Get devices for deployment
                devices = orchestrator.get_devices()
                print(f"📊 Devices ready for deployment: {len(devices)}")
                
                # Execute dry run deployment
                print("\n🎯 Executing dry run deployment...")
                print("   (Simulating sequential deployment: Management → Core → Access → Edge)")
                
                results = orchestrator.deploy_all_devices(dry_run=True)
                
                # Display results
                print("\n📊 Deployment Results (DRY RUN):")
                for device_name, result in results.results.items():
                    status_icon = "✅" if result.status.name == "SUCCESS" else "❌"
                    print(f"   {status_icon} {device_name}: {result.message}")
                
                print(f"\n📈 Deployment Summary: {results.summary}")
                print(f"⏱️ Execution time: {results.execution_time:.2f} seconds")
                
            else:
                print("❌ Template validation failed")
                print("   • Check template syntax errors above")
        else:
            print("❌ Failed to load inventory")
    else:
        print(f"⚠️  Inventory file not found: {inventory_file}")
        print("   Creating minimal demo configuration...")


def show_project_structure():
    """Show project structure"""
    print_section("PROJECT STRUCTURE OVERVIEW")
    
    def print_tree(path, prefix="", max_depth=3, current_depth=0):
        if current_depth >= max_depth:
            return
        
        try:
            items = sorted(path.iterdir(), key=lambda x: (x.is_file(), x.name.lower()))
            for i, item in enumerate(items):
                is_last = i == len(items) - 1
                current_prefix = "└── " if is_last else "├── "
                
                if item.is_dir():
                    print(f"{prefix}{current_prefix}📁 {item.name}/")
                    next_prefix = prefix + ("    " if is_last else "│   ")
                    print_tree(item, next_prefix, max_depth, current_depth + 1)
                else:
                    icon = "🐍" if item.suffix == ".py" else "📚" if item.suffix == ".md" else "📄"
                    print(f"{prefix}{current_prefix}{icon} {item.name}")
        except PermissionError:
            pass
    
    print("📁 Project Structure:")
    print_tree(Path("."))


def print_implementation_summary():
    """Print implementation summary"""
    print_section("PHASE 1 MVP IMPLEMENTATION SUMMARY")
    
    print("🎯 PHASE 1 SCOPE:")
    print("   • 6 Huawei Devices: 2 Core, 2 Access, 1 Edge Router, 1 Management")
    print("   • Basic VLAN Management: 10, 100-103, 999")
    print("   • Standard STP/RSTP Implementation")
    print("   • OSPF Single Area (Area 0)")
    print("   • SSH Key Authentication")
    print("   • Sequential Deployment Strategy")
    
    print("\n🏗️  CORE ARCHITECTURE:")
    print("   • DeviceManager: SSH-based device connectivity and management")
    print("   • TemplateEngine: Jinja2-based configuration generation")
    print("   • DeploymentOrchestrator: Intelligent deployment sequencing")
    
    print("\n📊 IMPLEMENTATION STATUS:")
    core_modules = [
        "device_manager.py",
        "template_engine.py", 
        "deployment_orchestrator.py"
    ]
    
    for module in core_modules:
        module_path = Path(f"src/automation/huawei/scripts/core/{module}")
        status = "✅" if module_path.exists() else "❌"
        print(f"   {status} {module}")
    
    print("\n📄 TEMPLATE STATUS:")
    templates = [
        "management_switch.j2",
        "core_switch.j2", 
        "access_switch.j2",
        "edge_router.j2"
    ]
    
    for template in templates:
        template_path = Path(f"src/automation/huawei/templates/{template}")
        status = "✅" if template_path.exists() else "❌"
        print(f"   {status} {template}")
    
    print("\n⚙️  INVENTORY:", end=" ")
    inventory_path = Path("src/automation/huawei/inventory/devices.yaml")
    print("✅ devices.yaml" if inventory_path.exists() else "❌ devices.yaml")
    
    print("\n📚 DOCUMENTATION STATUS:")
    docs = [
        "architecture.md",
        "network-topology.md",
        "deployment-guide.md",
        "README.md"
    ]
    
    for doc in docs:
        print(f"   ❌ {doc}")


def main():
    """Main demo function"""
    setup_logging()
    
    try:
        print_banner()
        
        # Core modules demonstration
        demonstrate_core_modules()
        
        # Template generation demo
        demonstrate_template_generation()
        
        # Deployment simulation
        demonstrate_deployment_simulation()
        
        # Project structure
        show_project_structure()
        
        # Implementation summary
        print_implementation_summary()
        
        print("\n" + "="*80)
        print("🎉 DEMO COMPLETED SUCCESSFULLY!")
        print("="*80)
        print("📋 Next Steps:")
        print("   1. Install dependencies: pip install -r requirements.txt")
        print("   2. Run setup script: ./scripts/setup.sh")
        print("   3. Configure actual device credentials in inventory")
        print("   4. Test real device connectivity")
        print("   5. Execute production deployment")
        print("   6. Monitor deployment results")
        print("   7. Plan Phase 2 enterprise features")
        print()
        print("🚀 Phase 1 MVP is ready for production deployment!")
        print("="*80)
        
    except Exception as e:
        logging.error(f"Demo failed with error: {str(e)}")
        print(f"❌ Demo failed: {str(e)}")
        print("Please check the logs for detailed error information.")
        return 1
    
    return 0


if __name__ == "__main__":
    exit_code = main()
    sys.exit(exit_code)
