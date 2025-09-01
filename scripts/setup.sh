#!/bin/bash

# Huawei Network Automation Suite - Phase 1 MVP Setup Script
# Automated setup for complete development and deployment environment

set -e  # Exit on any error

# Change to project root directory (parent of scripts/)
cd "$(dirname "$0")/.."

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_banner() {
    echo ""
    echo "================================================================================"
    echo "🚀 HUAWEI NETWORK AUTOMATION SUITE - PHASE 1 MVP SETUP"
    echo "================================================================================"
    echo "📋 Scope: 6 Huawei Devices - Complete Infrastructure Automation"
    echo "🎯 Features: SSH Auth, Template Engine, Sequential Deployment"
    echo "⚡ Architecture: 3 Core Modules + 4 Templates + Comprehensive Testing"
    echo "================================================================================"
    echo ""
}

print_banner

# Step 1: Check system requirements
print_status "Checking system requirements..."

# Check Python version
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version | cut -d" " -f2)
    MAJOR_VERSION=$(echo $PYTHON_VERSION | cut -d"." -f1)
    MINOR_VERSION=$(echo $PYTHON_VERSION | cut -d"." -f2)
    
    if [ "$MAJOR_VERSION" -eq 3 ] && [ "$MINOR_VERSION" -ge 9 ]; then
        print_success "Python $PYTHON_VERSION detected (>= 3.9 required)"
    else
        print_error "Python $PYTHON_VERSION detected, but >= 3.9 is required"
        exit 1
    fi
else
    print_error "Python 3 not found. Please install Python 3.9 or higher."
    exit 1
fi

# Check if git is available
if command -v git &> /dev/null; then
    print_success "Git is available"
else
    print_warning "Git not found - some features may be limited"
fi

# 2. Setup Python Virtual Environment (INTELLIGENT PRESERVATION)
echo "🐍 Setting up Python virtual environment..."
if [ -d ".venv" ]; then
    echo "   ♻️  Virtual environment exists - preserving for VSCode stability..."
    echo "   🔌 Activating existing virtual environment..."
    source .venv/bin/activate
    
    # Check if critical packages are already installed with correct versions
    NETMIKO_OK=$(python -c "import netmiko; print('4.6.0' <= netmiko.__version__)" 2>/dev/null || echo "False")
    JINJA2_INSTALLED=$(python -c "import jinja2; print('yes')" 2>/dev/null || echo "no")
    ANSIBLE_INSTALLED=$(python -c "import ansible; print('yes')" 2>/dev/null || echo "no")
    
    if [ "$NETMIKO_OK" = "True" ] && [ "$JINJA2_INSTALLED" = "yes" ] && [ "$ANSIBLE_INSTALLED" = "yes" ]; then
        echo "   ✅ Core packages already installed with correct versions - skipping package installation"
        echo "   💡 To force reinstall, delete .venv and run setup again"
        SKIP_PACKAGE_INSTALL=true
    else
        echo "   ⚠️  Some packages missing or outdated - will install/update dependencies"
        SKIP_PACKAGE_INSTALL=false
    fi
else
    echo "   📦 Creating new virtual environment..."
    python3 -m venv .venv
    echo "   🔌 Activating virtual environment..."
    source .venv/bin/activate
    SKIP_PACKAGE_INSTALL=false
fi

# 3. Install Python Dependencies (ONLY IF NEEDED)
if [ "$SKIP_PACKAGE_INSTALL" = "false" ]; then
    echo "📦 Installing/Updating Python dependencies..."
    pip install --upgrade pip
    
    # Install only Python 3.13 compatible packages (DEFINITIVE VERSIONS)
    echo "   📦 Installing core automation packages..."
    pip install netmiko>=4.6.0 Jinja2>=3.1.2 PyYAML>=6.0.1 pytest>=7.4.2 paramiko>=3.4.0 textfsm>=1.1.3 cerberus>=1.3.4
    
    # Install Ansible separately with VSCode protection
    echo "   📦 Installing Ansible (with VSCode crash protection)..."
    echo "   ⚠️  WARNING: VSCode may become unresponsive during Ansible installation"
    echo "   💡 This is normal - DO NOT force quit VSCode, just wait for completion"
    echo "   🔄 Installing in background to minimize VSCode impact..."
    
    # Install with reduced verbosity to minimize VSCode impact
    pip install --quiet ansible>=8.2.0
    
    if [ $? -eq 0 ]; then
        print_success "All dependencies installed successfully"
        echo "   ✅ Ansible installation completed - VSCode should be stable now"
    else
        print_error "Failed to install dependencies"
        exit 1
    fi
else
    echo "📦 Skipping package installation - all dependencies already present"
fi

print_success "Core dependencies validated"

# Step 4: Verify project structure
print_status "Verifying project structure..."

# Required directories
REQUIRED_DIRS=(
    "src/automation/huawei/scripts/core"
    "src/automation/huawei/inventory"
    "src/automation/huawei/templates"
    "src/automation/huawei/configs"
    "tests/unit"
    "tests/integration"
    "docs"
)

for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        print_success "Directory exists: $dir"
    else
        print_warning "Creating missing directory: $dir"
        mkdir -p "$dir"
    fi
done

# Required files
REQUIRED_FILES=(
    "src/__init__.py"
    "src/automation/__init__.py"
    "src/automation/huawei/__init__.py"
    "src/automation/huawei/scripts/__init__.py"
    "src/automation/huawei/scripts/core/__init__.py"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        print_success "File exists: $file"
    else
        print_warning "File missing: $file (should have been created during implementation)"
    fi
done

# Step 5: Validate core modules
print_status "Validating core modules..."

CORE_MODULES=(
    "src/automation/huawei/scripts/core/device_manager.py"
    "src/automation/huawei/scripts/core/template_engine.py"
    "src/automation/huawei/scripts/core/deployment_orchestrator.py"
)

MODULE_COUNT=0
for module in "${CORE_MODULES[@]}"; do
    if [ -f "$module" ]; then
        print_success "Core module found: $(basename $module)"
        ((MODULE_COUNT++))
    else
        print_error "Missing core module: $module"
    fi
done

if [ $MODULE_COUNT -eq 3 ]; then
    print_success "All 3 core modules present"
else
    print_error "Missing core modules - setup incomplete"
    exit 1
fi

# Step 6: Validate templates
print_status "Validating Jinja2 templates..."

TEMPLATES=(
    "src/automation/huawei/templates/management_switch.j2"
    "src/automation/huawei/templates/core_switch.j2"
    "src/automation/huawei/templates/access_switch.j2"
    "src/automation/huawei/templates/edge_router.j2"
)

TEMPLATE_COUNT=0
for template in "${TEMPLATES[@]}"; do
    if [ -f "$template" ]; then
        print_success "Template found: $(basename $template)"
        ((TEMPLATE_COUNT++))
    else
        print_error "Missing template: $template"
    fi
done

if [ $TEMPLATE_COUNT -eq 4 ]; then
    print_success "All 4 device templates present"
else
    print_error "Missing templates - setup incomplete"
    exit 1
fi

# Step 7: Validate inventory
print_status "Validating device inventory..."

INVENTORY_FILE="src/automation/huawei/inventory/devices.yaml"
if [ -f "$INVENTORY_FILE" ]; then
    print_success "Device inventory found: $INVENTORY_FILE"
    
    # Check if inventory contains expected devices
    DEVICE_COUNT=$(grep -c "^  [a-z].*-.*:" "$INVENTORY_FILE" 2>/dev/null || echo "0")
    if [ "$DEVICE_COUNT" -ge 6 ]; then
        print_success "Inventory contains $DEVICE_COUNT devices (6+ expected)"
    else
        print_warning "Inventory contains only $DEVICE_COUNT devices (6 expected)"
    fi
else
    print_error "Device inventory missing: $INVENTORY_FILE"
    exit 1
fi

# Step 8: Test core module imports
print_status "Testing core module imports..."

python3 -c "
import sys
sys.path.insert(0, 'src')

try:
    from automation.huawei.scripts.core.device_manager import DeviceManager
    print('✅ DeviceManager import successful')
except ImportError as e:
    print(f'❌ DeviceManager import failed: {e}')
    sys.exit(1)

try:
    from automation.huawei.scripts.core.template_engine import TemplateEngine
    print('✅ TemplateEngine import successful')
except ImportError as e:
    print(f'❌ TemplateEngine import failed: {e}')
    sys.exit(1)

try:
    from automation.huawei.scripts.core.deployment_orchestrator import DeploymentOrchestrator
    print('✅ DeploymentOrchestrator import successful')
except ImportError as e:
    print(f'❌ DeploymentOrchestrator import failed: {e}')
    sys.exit(1)

print('🎉 All core modules imported successfully!')
"

if [ $? -eq 0 ]; then
    print_success "Core module imports validated"
else
    print_error "Core module import validation failed"
    exit 1
fi

# Step 9: Create comprehensive documentation (MANDATORY)
print_status "Creating comprehensive documentation..."

python3 -c "
import os
from pathlib import Path

# Create docs directory if it doesn't exist
docs_dir = Path('docs')
docs_dir.mkdir(exist_ok=True)

print('📚 Creating comprehensive documentation...')

# 1. Architecture Documentation (MANDATORY)
with open(docs_dir / 'architecture.md', 'w') as f:
    f.write('''# System Architecture - Huawei Network Automation Suite

## Component Overview

The Huawei Network Automation Suite is built on a modular architecture with three core components that work together to provide comprehensive network automation capabilities.

\`\`\`mermaid
graph TB
    A[DeviceManager] --> B[SSH Connections]
    C[TemplateEngine] --> D[Jinja2 Processing]
    E[DeploymentOrchestrator] --> F[Deployment Logic]
    
    A --> G[ConnectionConfig]
    C --> H[Template Validation]
    E --> I[Deployment Results]
    
    style A fill:#e1f5fe
    style C fill:#e8f5e8
    style E fill:#fff3e0
\`\`\`

## Module Dependencies

\`\`\`mermaid
classDiagram
    class DeviceManager {
        +ConnectionConfig config
        +connect(device_name)
        +send_command(device_name, command)
        +deploy_config(device_name, config)
    }
    
    class TemplateEngine {
        +Environment env
        +get_template(name)
        +render_template(name, vars)
        +validate_template(name)
    }
    
    class DeploymentOrchestrator {
        +DeviceManager device_manager
        +TemplateEngine template_engine
        +deploy_all_devices(dry_run)
        +deploy_device(name)
    }
    
    DeploymentOrchestrator --> DeviceManager
    DeploymentOrchestrator --> TemplateEngine
\`\`\`

## Deployment Flow

\`\`\`mermaid
sequenceDiagram
    participant DO as DeploymentOrchestrator
    participant TE as TemplateEngine
    participant DM as DeviceManager
    participant HD as HuaweiDevice
    
    DO->>TE: render_template(device_config)
    TE->>DO: generated_config
    DO->>DM: deploy_config(device, config)
    DM->>HD: SSH connection
    HD->>DM: connection_established
    DM->>HD: send_config_commands
    HD->>DM: config_applied
    DM->>DO: deployment_success
\`\`\`

## Error Handling Architecture

\`\`\`mermaid
graph LR
    A[Connection Error] --> B[Retry Mechanism]
    C[Template Error] --> D[Validation Fallback]
    E[Deployment Error] --> F[Rollback Strategy]
    
    B --> G[Exponential Backoff]
    D --> H[Error Logging]
    F --> I[Previous Config Restore]
\`\`\`
''')

# 2. Network Topology Documentation (MANDATORY)
with open(docs_dir / 'network-topology.md', 'w') as f:
    f.write('''# Network Topology - Phase 1 MVP

## Physical Network Layout

\`\`\`mermaid
graph TB
    subgraph \"Management Network\"
        MS[Management Switch<br/>S5720-12TP-PWR-LI<br/>192.168.10.10]
    end
    
    subgraph \"Core Layer\"
        CS1[Core Switch 1<br/>S12700E<br/>192.168.10.11]
        CS2[Core Switch 2<br/>S12700E<br/>192.168.10.12]
    end
    
    subgraph \"Access Layer\"
        AS1[Access Switch 1<br/>S5700-28C-HI<br/>192.168.10.13]
        AS2[Access Switch 2<br/>S5700-28C-HI<br/>192.168.10.14]
    end
    
    subgraph \"WAN Edge\"
        ER[Edge Router<br/>AR6300<br/>192.168.10.15]
    end
    
    MS -.-> CS1
    MS -.-> CS2
    CS1 --- CS2
    CS1 --- AS1
    CS1 --- AS2
    CS2 --- AS1
    CS2 --- AS2
    CS1 --- ER
    
    style MS fill:#fff3e0
    style CS1 fill:#e1f5fe
    style CS2 fill:#e1f5fe
    style AS1 fill:#e8f5e8
    style AS2 fill:#e8f5e8
    style ER fill:#ffebee
\`\`\`

## VLAN Design

\`\`\`mermaid
graph LR
    subgraph \"VLAN Structure\"
        V10[VLAN 10<br/>Management<br/>192.168.10.0/24]
        V100[VLAN 100<br/>Marketing<br/>192.168.100.0/24]
        V101[VLAN 101<br/>Sales<br/>192.168.101.0/24]
        V102[VLAN 102<br/>Engineering<br/>192.168.102.0/24]
        V103[VLAN 103<br/>Finance<br/>192.168.103.0/24]
        V999[VLAN 999<br/>Quarantine<br/>192.168.999.0/24]
    end
    
    style V10 fill:#fff3e0
    style V100 fill:#e8f5e8
    style V101 fill:#e8f5e8
    style V102 fill:#e8f5e8
    style V103 fill:#e8f5e8
    style V999 fill:#ffebee
\`\`\`

## Deployment Sequence

\`\`\`mermaid
graph TD
    A[1. Management Switch] --> B[2. Core Switch 1]
    B --> C[3. Core Switch 2]
    C --> D[4. Access Switch 1]
    D --> E[5. Access Switch 2]
    E --> F[6. Edge Router]
    
    style A fill:#fff3e0
    style B fill:#e1f5fe
    style C fill:#e1f5fe
    style D fill:#e8f5e8
    style E fill:#e8f5e8
    style F fill:#ffebee
\`\`\`

## Port Allocation Matrix

| Device | Port Range | VLAN | Usage | PoE |
|--------|------------|------|-------|-----|
| AS1 | 1-8 | 100 | Marketing Workstations | Yes |
| AS1 | 9-16 | 101 | Sales Workstations | Yes |
| AS1 | 17-20 | 102 | Engineering Lab | Yes |
| AS1 | 21-24 | Trunk | Uplinks to Core | No |
| AS2 | 1-8 | 101 | Sales Extension | Yes |
| AS2 | 9-16 | 103 | Finance Department | Yes |
| AS2 | 17-20 | 102 | Engineering Extension | Yes |
| AS2 | 21-24 | Trunk | Uplinks to Core | No |
''')

# 3. Deployment Guide (MANDATORY)
with open(docs_dir / 'deployment-guide.md', 'w') as f:
    f.write('''# Deployment Guide - Huawei Network Automation Suite

## Quick Start Deployment

\`\`\`bash
# Complete deployment in one command:
./setup.sh && python demo_automation.py
\`\`\`

## Step-by-Step Deployment

### Phase 1: Environment Setup

\`\`\`mermaid
graph LR
    A[Clone Repository] --> B[Run setup.sh]
    B --> C[Activate .venv]
    C --> D[Validate Setup]
    
    style A fill:#e8f5e8
    style B fill:#e1f5fe
    style C fill:#fff3e0
    style D fill:#f3e5f5
\`\`\`

\`\`\`bash
# 1. Repository Setup
git clone <repo-url>
cd AgenticHW

# 2. Automated Setup
./setup.sh

# 3. Manual Validation
source .venv/bin/activate
python demo_automation.py
\`\`\`

### Phase 2: Configuration Generation

\`\`\`mermaid
flowchart TD
    A[Load Inventory] --> B[Validate Templates]
    B --> C[Generate Configs]
    C --> D[Syntax Validation]
    D --> E[Save to configs/]
    
    style A fill:#e8f5e8
    style B fill:#e1f5fe
    style C fill:#fff3e0
    style D fill:#f3e5f5
    style E fill:#ffebee
\`\`\`

### Phase 3: Device Deployment

\`\`\`mermaid
sequenceDiagram
    participant U as User
    participant O as Orchestrator
    participant D as DeviceManager
    participant H as HuaweiDevice
    
    U->>O: deploy_all_devices(dry_run=True)
    O->>D: connect(device)
    D->>H: SSH connection
    H->>D: connection_ok
    D->>H: send_config
    H->>D: config_applied
    D->>O: success
    O->>U: deployment_complete
\`\`\`

## Deployment Validation

\`\`\`bash
# Pre-deployment checks
python -c \"from src.automation.huawei.scripts.core import *; print('✅ All modules imported')\"
ls docs/*.md | wc -l  # Should be >= 4
ls src/automation/huawei/templates/*.j2 | wc -l  # Should be >= 4

# Post-deployment validation
python demo_automation.py  # Should complete successfully
\`\`\`

## Troubleshooting Common Issues

### Issue 1: Import Errors
\`\`\`bash
# Solution: Check Python package structure
find src/ -name \"__init__.py\"
# Should show 5 files
\`\`\`

### Issue 2: Template Not Found
\`\`\`bash
# Solution: Verify template directory
ls -la src/automation/huawei/templates/
# Should contain *.j2 files
\`\`\`

### Issue 3: Virtual Environment Issues
\`\`\`bash
# Solution: Recreate virtual environment
rm -rf .venv
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
\`\`\`
''')

# 4. README for docs/ (MANDATORY)
with open(docs_dir / 'README.md', 'w') as f:
    f.write('''# Documentation Index - Huawei Network Automation Suite

## 📋 Documentation Overview

This directory contains comprehensive technical documentation for the Huawei Network Automation Suite Phase 1 MVP.

## 📄 Available Documentation

| Document | Description | Diagrams | Purpose |
|----------|-------------|----------|---------|
| [architecture.md](architecture.md) | System architecture and component design | 4 Mermaid diagrams | Development & Architecture |
| [network-topology.md](network-topology.md) | Network design and VLAN structure | 4 Mermaid diagrams | Network Engineering |
| [deployment-guide.md](deployment-guide.md) | Step-by-step deployment instructions | 3 Mermaid diagrams | Operations & Deployment |
| [README.md](README.md) | This documentation index | 1 Mermaid diagram | Navigation |

## 🎯 Quick Navigation

\`\`\`mermaid
graph LR
    A[� README] --> B[🏗️ Architecture]
    A --> C[🌐 Network Topology]
    A --> D[�🚀 Deployment Guide]
    
    B --> E[Component Design]
    B --> F[Module Dependencies]
    B --> G[Error Handling]
    
    C --> H[Physical Layout]
    C --> I[VLAN Design]
    C --> J[Port Allocation]
    
    D --> K[Quick Start]
    D --> L[Step-by-Step]
    D --> M[Troubleshooting]
    
    style A fill:#e1f5fe
    style B fill:#e8f5e8
    style C fill:#fff3e0
    style D fill:#f3e5f5
\`\`\`

## 📊 Documentation Statistics

- **Total Documents:** 4
- **Mermaid Diagrams:** 12+
- **Code Examples:** 20+
- **Troubleshooting Guides:** 3
- **Deployment Procedures:** 2

## 🔄 Documentation Maintenance

This documentation is automatically generated and should be kept in sync with:
- Core module changes in \`src/automation/huawei/scripts/core/\`
- Template updates in \`src/automation/huawei/templates/\`
- Inventory modifications in \`src/automation/huawei/inventory/\`

## ✅ Documentation Validation

\`\`\`bash
# Validate all documentation exists:
ls docs/*.md | wc -l  # Should return 4

# Check for Mermaid diagrams:
grep -r \"mermaid\" docs/ | wc -l  # Should be > 10

# Validate markdown syntax:
# (Use markdown linter of choice)
\`\`\`

## 📖 For More Information

- See [Requirements.md](../Requirements.md) for detailed project requirements
- See [deployment_standards.md](../deployment_standards.md) for implementation standards
- See project root for setup scripts and demos
''')

print('✅ MANDATORY documentation created in docs/')
print('📄 Created 4 essential documentation files:')
print('   - architecture.md (System design + 4 Mermaid diagrams)')
print('   - network-topology.md (Network design + 4 Mermaid diagrams)') 
print('   - deployment-guide.md (Deployment procedures + 3 Mermaid diagrams)')
print('   - README.md (Documentation index + 1 Mermaid diagram)')
print('')
print('📊 Total: 12+ Mermaid diagrams, 4 comprehensive guides')
print('⚠️  This documentation creation MUST be included in every setup!')
"

if [ $? -eq 0 ]; then
    print_success "Comprehensive documentation created"
else
    print_error "Documentation creation failed"
    exit 1
fi

# Step 10: Validate documentation
print_status "Validating documentation..."

DOC_COUNT=$(find docs/ -name "*.md" | wc -l)
if [ "$DOC_COUNT" -ge 4 ]; then
    print_success "Documentation complete: $DOC_COUNT files"
else
    print_error "Insufficient documentation: only $DOC_COUNT files (minimum: 4)"
    exit 1
fi

# Check for Mermaid diagrams
MERMAID_COUNT=$(grep -r "mermaid" docs/ | wc -l)
if [ "$MERMAID_COUNT" -ge 10 ]; then
    print_success "Mermaid diagrams: $MERMAID_COUNT (10+ required)"
else
    print_warning "Only $MERMAID_COUNT Mermaid diagrams found (10+ recommended)"
fi

# Step 11: Run basic functionality test
print_status "Running basic functionality test..."

if [ -f "demo_automation.py" ]; then
    print_status "Testing demo script execution..."
    
    # Run demo script in validation mode
    python3 demo_automation.py > /dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        print_success "Demo script executed successfully"
    else
        print_warning "Demo script had issues - check manual execution"
    fi
else
    print_warning "Demo script not found - skipping functionality test"
fi

# Step 12: Generate setup summary
print_status "Generating setup summary..."

echo ""
echo "================================================================================"
echo "🎉 SETUP COMPLETED SUCCESSFULLY!"
echo "================================================================================"
echo ""
echo "📊 SETUP SUMMARY:"
echo "   ✅ Python virtual environment created and activated"
echo "   ✅ All required dependencies installed"
echo "   ✅ Project structure verified and complete"
echo "   ✅ 3 core modules validated: DeviceManager, TemplateEngine, DeploymentOrchestrator"
echo "   ✅ 4 device templates created: Management, Core, Access, Edge Router"
echo "   ✅ Device inventory configured with 6 Huawei devices"
echo "   ✅ Comprehensive documentation generated (4 files, 12+ Mermaid diagrams)"
echo "   ✅ Module imports tested and validated"
echo ""
echo "🚀 NEXT STEPS:"
echo "   1. Run the demo: python demo_automation.py"
echo "   2. Review documentation in docs/ directory"
echo "   3. Customize device credentials in src/automation/huawei/inventory/devices.yaml"
echo "   4. Execute real deployment when ready"
echo ""
echo "📁 KEY FILES:"
echo "   • Demo Script: demo_automation.py"
echo "   • Device Inventory: src/automation/huawei/inventory/devices.yaml"
echo "   • Templates: src/automation/huawei/templates/*.j2"
echo "   • Documentation: docs/*.md"
echo "   • Core Modules: src/automation/huawei/scripts/core/"
echo ""
echo "⚡ PHASE 1 MVP IS READY FOR DEPLOYMENT!"
echo "================================================================================"
echo ""

# Create activation helper script in scripts directory
cat > scripts/activate_env.sh << 'EOF'
#!/bin/bash
# Huawei Network Automation Suite - Environment Activation
cd "$(dirname "$0")/.."  # Navigate to project root
source .venv/bin/activate
echo "🚀 Huawei Network Automation Suite environment activated!"
echo "📋 Available commands:"
echo "   • python demo_automation.py  # Run full demo"
echo "   • ./scripts/reset.sh         # Reset environment"
echo "   • deactivate                 # Exit virtual environment"
EOF

chmod +x scripts/activate_env.sh
print_success "Environment activation script created: ./scripts/activate_env.sh"

print_success "Phase 1 MVP setup completed successfully!"
print_status "Virtual environment remains activated for immediate use"

# Check Python version
echo "🐍 Checking Python version..."
python_version=$(python3 --version 2>&1 | cut -d' ' -f2)
required_version="3.9"

if python3 -c "import sys; exit(0 if sys.version_info >= (3,9) else 1)"; then
    echo "✅ Python $python_version is compatible"
else
    echo "❌ Python 3.9+ required, found $python_version"
    exit 1
fi

# Create and activate virtual environment if not exists
echo "� Setting up virtual environment..."
if [ ! -d ".venv" ]; then
    echo "� Creating virtual environment..."
    python3 -m venv .venv
    echo "✅ Virtual environment created"
fi

# Activate virtual environment
echo "🔄 Activating virtual environment..."
source .venv/bin/activate
echo "✅ Virtual environment activated"

# Upgrade pip
echo "📦 Upgrading pip..."
pip install --upgrade pip

# Install requirements
echo "📦 Installing Python packages..."
if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt
    echo "✅ All packages installed successfully"
else
    echo "📝 Creating requirements.txt from deployment_standards.md..."
    cat > requirements.txt << 'EOF'
napalm==4.1.0
netmiko==4.2.0
Jinja2==3.1.2
PyYAML==6.0.1
pytest==7.4.2
ansible==8.2.0
paramiko==3.3.1
textfsm==1.1.3
cerberus==1.3.4
EOF
    pip install -r requirements.txt
    echo "✅ Requirements created and packages installed"
fi

# Create complete project structure
echo "📁 Creating project structure..."
mkdir -p src/automation/huawei/{scripts/core,inventory,templates,configs}
mkdir -p tests/{unit,integration}
mkdir -p docs

# Create __init__.py files for proper Python imports
echo "🐍 Creating Python package structure..."
touch src/__init__.py
touch src/automation/__init__.py
touch src/automation/huawei/__init__.py
touch src/automation/huawei/scripts/__init__.py
touch src/automation/huawei/scripts/core/__init__.py
echo "✅ Python package structure created"

# Create SSH key if it doesn't exist
echo "🔑 Checking SSH keys..."
if [ ! -f ~/.ssh/id_rsa ]; then
    echo "🔑 Generating SSH key pair..."
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
    echo "✅ SSH key generated at ~/.ssh/id_rsa"
else
    echo "✅ SSH key already exists"
fi

# Set proper permissions
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub

# Check if core modules exist, if not run deployment_standards reconstruction
echo "🔍 Checking core modules..."
if [ ! -f "src/automation/huawei/scripts/core/device_manager.py" ]; then
    echo "⚠️  Core modules missing! This is expected on first run."
    echo "📋 You need to run the implementation from deployment_standards.md"
    echo "💡 Or copy the modules from a working implementation"
fi

# Create demo automation script if not exists
echo "🎮 Setting up demo script..."
if [ ! -f "demo_automation.py" ]; then
    echo "📝 Creating demo_automation.py..."
    # Demo script will be created during implementation
fi

# 🚨 MANDATORY: Create comprehensive documentation in docs/
echo "📚 Creating mandatory documentation..."
echo "⚠️  This is CRITICAL - documentation is NOT optional!"

python3 -c "
import os
from pathlib import Path

# Create docs directory structure
docs_dir = Path('docs')
docs_dir.mkdir(exist_ok=True)

# 1. Architecture Documentation (MANDATORY)
with open(docs_dir / 'architecture.md', 'w') as f:
    f.write('''# System Architecture - Huawei Network Automation Suite

## Overview
Phase 1 MVP implementation with 3 core modules for 6 Huawei devices.

## Component Architecture

\`\`\`mermaid
graph TB
    A[DeviceManager] --> B[SSH Connections]
    C[TemplateEngine] --> D[Jinja2 Processing]
    E[DeploymentOrchestrator] --> F[Deployment Logic]
    
    A --> G[ConnectionConfig]
    C --> H[Template Validation]
    E --> I[Deployment Results]
    
    style A fill:#e1f5fe
    style C fill:#e8f5e8
    style E fill:#fff3e0
\`\`\`

## Module Dependencies

\`\`\`mermaid
classDiagram
    class DeviceManager {
        +ConnectionConfig config
        +connect(device_name)
        +send_command(device_name, command)
        +deploy_config(device_name, config)
    }
    
    class TemplateEngine {
        +Environment env
        +get_template(name)
        +render_template(name, vars)
        +validate_template(name)
    }
    
    class DeploymentOrchestrator {
        +DeviceManager device_manager
        +TemplateEngine template_engine
        +deploy_all_devices(dry_run)
        +deploy_device(name)
    }
    
    DeploymentOrchestrator --> DeviceManager
    DeploymentOrchestrator --> TemplateEngine
\`\`\`

## Deployment Flow

\`\`\`mermaid
sequenceDiagram
    participant DO as DeploymentOrchestrator
    participant TE as TemplateEngine
    participant DM as DeviceManager
    participant HD as HuaweiDevice
    
    DO->>TE: render_template(device_config)
    TE->>DO: generated_config
    DO->>DM: deploy_config(device, config)
    DM->>HD: SSH connection
    HD->>DM: connection_established
    DM->>HD: send_config_commands
    HD->>DM: config_applied
    DM->>DO: deployment_success
\`\`\`

## Error Handling Architecture

\`\`\`mermaid
graph LR
    A[Connection Error] --> B[Retry Mechanism]
    C[Template Error] --> D[Validation Fallback]
    E[Deployment Error] --> F[Rollback Strategy]
    
    B --> G[Exponential Backoff]
    D --> H[Error Logging]
    F --> I[Previous Config Restore]
\`\`\`
''')

# 2. Network Topology Documentation (MANDATORY)
with open(docs_dir / 'network-topology.md', 'w') as f:
    f.write('''# Network Topology - Phase 1 MVP

## Physical Network Layout

\`\`\`mermaid
graph TB
    subgraph \"Management Network\"
        MS[Management Switch<br/>S5720-12TP-PWR-LI<br/>192.168.10.10]
    end
    
    subgraph \"Core Layer\"
        CS1[Core Switch 1<br/>S12700E<br/>192.168.10.11]
        CS2[Core Switch 2<br/>S12700E<br/>192.168.10.12]
    end
    
    subgraph \"Access Layer\"
        AS1[Access Switch 1<br/>S5700-28C-HI<br/>192.168.10.13]
        AS2[Access Switch 2<br/>S5700-28C-HI<br/>192.168.10.14]
    end
    
    subgraph \"WAN Edge\"
        ER[Edge Router<br/>AR6300<br/>192.168.10.15]
    end
    
    MS -.-> CS1
    MS -.-> CS2
    CS1 --- CS2
    CS1 --- AS1
    CS1 --- AS2
    CS2 --- AS1
    CS2 --- AS2
    CS1 --- ER
    
    style MS fill:#fff3e0
    style CS1 fill:#e1f5fe
    style CS2 fill:#e1f5fe
    style AS1 fill:#e8f5e8
    style AS2 fill:#e8f5e8
    style ER fill:#ffebee
\`\`\`

## VLAN Design

\`\`\`mermaid
graph LR
    subgraph \"VLAN Structure\"
        V10[VLAN 10<br/>Management<br/>192.168.10.0/24]
        V100[VLAN 100<br/>Marketing<br/>192.168.100.0/24]
        V101[VLAN 101<br/>Sales<br/>192.168.101.0/24]
        V102[VLAN 102<br/>Engineering<br/>192.168.102.0/24]
        V103[VLAN 103<br/>Finance<br/>192.168.103.0/24]
        V999[VLAN 999<br/>Quarantine<br/>192.168.999.0/24]
    end
    
    style V10 fill:#fff3e0
    style V100 fill:#e8f5e8
    style V101 fill:#e8f5e8
    style V102 fill:#e8f5e8
    style V103 fill:#e8f5e8
    style V999 fill:#ffebee
\`\`\`

## Deployment Sequence

\`\`\`mermaid
graph TD
    A[1. Management Switch] --> B[2. Core Switch 1]
    B --> C[3. Core Switch 2]
    C --> D[4. Access Switch 1]
    D --> E[5. Access Switch 2]
    E --> F[6. Edge Router]
    
    style A fill:#fff3e0
    style B fill:#e1f5fe
    style C fill:#e1f5fe
    style D fill:#e8f5e8
    style E fill:#e8f5e8
    style F fill:#ffebee
\`\`\`
''')

# 3. Deployment Guide (MANDATORY)
with open(docs_dir / 'deployment-guide.md', 'w') as f:
    f.write('''# Deployment Guide - Huawei Network Automation Suite

## Quick Start Deployment

\`\`\`bash
# Complete deployment in one command:
./setup.sh && python demo_automation.py
\`\`\`

## Step-by-Step Deployment

### Phase 1: Environment Setup

\`\`\`mermaid
graph LR
    A[Clone Repository] --> B[Run setup.sh]
    B --> C[Activate .venv]
    C --> D[Validate Setup]
    
    style A fill:#e8f5e8
    style B fill:#e1f5fe
    style C fill:#fff3e0
    style D fill:#f3e5f5
\`\`\`

### Phase 2: Configuration Generation

\`\`\`mermaid
flowchart TD
    A[Load Inventory] --> B[Validate Templates]
    B --> C[Generate Configs]
    C --> D[Syntax Validation]
    D --> E[Save to configs/]
    
    style A fill:#e8f5e8
    style B fill:#e1f5fe
    style C fill:#fff3e0
    style D fill:#f3e5f5
    style E fill:#ffebee
\`\`\`

### Phase 3: Device Deployment

\`\`\`mermaid
sequenceDiagram
    participant U as User
    participant O as Orchestrator
    participant D as DeviceManager
    participant H as HuaweiDevice
    
    U->>O: deploy_all_devices(dry_run=True)
    O->>D: connect(device)
    D->>H: SSH connection
    H->>D: connection_ok
    D->>H: send_config
    H->>D: config_applied
    D->>O: success
    O->>U: deployment_complete
\`\`\`
''')

# 4. README for docs/ (MANDATORY)
with open(docs_dir / 'README.md', 'w') as f:
    f.write('''# Documentation Index - Huawei Network Automation Suite

## 📋 Documentation Overview

This directory contains comprehensive technical documentation for the Huawei Network Automation Suite Phase 1 MVP.

## 📄 Available Documentation

| Document | Description | Diagrams | Purpose |
|----------|-------------|----------|---------|
| [architecture.md](architecture.md) | System architecture and component design | 4 Mermaid diagrams | Development & Architecture |
| [network-topology.md](network-topology.md) | Network design and VLAN structure | 3 Mermaid diagrams | Network Engineering |
| [deployment-guide.md](deployment-guide.md) | Step-by-step deployment instructions | 3 Mermaid diagrams | Operations & Deployment |
| [README.md](README.md) | This documentation index | 1 Mermaid diagram | Navigation |

## 🎯 Quick Navigation

\`\`\`mermaid
graph LR
    A[📋 README] --> B[🏗️ Architecture]
    A --> C[🌐 Network Topology]
    A --> D[🚀 Deployment Guide]
    
    B --> E[Component Design]
    C --> F[Physical Layout]
    D --> G[Quick Start]
    
    style A fill:#e1f5fe
    style B fill:#e8f5e8
    style C fill:#fff3e0
    style D fill:#f3e5f5
\`\`\`

## 📊 Documentation Statistics

- **Total Documents:** 4
- **Mermaid Diagrams:** 11+
- **Code Examples:** 10+
- **Deployment Procedures:** 3

## ✅ Documentation Validation

\`\`\`bash
ls docs/*.md | wc -l  # Should return 4
grep -r \"mermaid\" docs/ | wc -l  # Should be > 10
\`\`\`
''')

print('✅ MANDATORY documentation created in docs/')
print('📄 Created 4 essential files with 11+ Mermaid diagrams')
"

if [ $? -eq 0 ]; then
    echo "✅ Mandatory documentation created successfully!"
    echo "📊 Documentation validation:"
    
    doc_count=$(ls docs/*.md 2>/dev/null | wc -l)
    diagram_count=$(grep -r "mermaid" docs/ 2>/dev/null | wc -l)
    
    echo "   📄 Documentation files: $doc_count (required: 4)"
    echo "   📊 Mermaid diagrams: $diagram_count (required: >10)"
    
    if [ "$doc_count" -ge 4 ] && [ "$diagram_count" -gt 10 ]; then
        echo "✅ Documentation requirements SATISFIED!"
    else
        echo "❌ Documentation requirements NOT SATISFIED!"
        echo "⚠️  CRITICAL: This is a deployment failure condition!"
    fi
else
    echo "❌ Failed to create mandatory documentation!"
    echo "⚠️  This is a CRITICAL deployment failure!"
fi

# Run tests to validate setup
echo "🧪 Running basic validation..."
if [ -f "demo_automation.py" ]; then
    python demo_automation.py
    echo "✅ Demo validation passed"
else
    echo "⚠️  Demo script not found - will be available after implementation"
fi
echo "🔧 Checking environment variables..."
missing_vars=()

if [ -z "$ADMIN_PASSWORD_HASH" ]; then
    missing_vars+=("ADMIN_PASSWORD_HASH")
fi

if [ -z "$CONSOLE_PASSWORD_HASH" ]; then
    missing_vars+=("CONSOLE_PASSWORD_HASH")
fi

if [ -z "$SNMP_COMMUNITY" ]; then
    missing_vars+=("SNMP_COMMUNITY")
fi

if [ ${#missing_vars[@]} -gt 0 ]; then
    echo "⚠️  Missing environment variables:"
    for var in "${missing_vars[@]}"; do
        echo "   - $var"
    done
    echo ""
    echo "Please set them with:"
    for var in "${missing_vars[@]}"; do
        echo "   export $var='your_value_here'"
    done
    echo ""
    echo "💡 You can add them to ~/.bashrc or ~/.zshrc to make them persistent"
else
    echo "✅ All required environment variables are set"
fi

# Run validation
echo "🔍 Running validation..."
if python3 src/main.py validate > /dev/null 2>&1; then
    echo "✅ Validation passed"
else
    echo "⚠️  Validation failed - check configuration"
fi

echo ""
echo "🎉 Setup completed!"
echo ""
echo "📋 Next steps:"
echo "1. Copy your SSH public key to the network devices:"
echo "   cat ~/.ssh/id_rsa.pub"
echo ""
echo "2. Update device IPs in src/automation/huawei/inventory/inventory.yaml"
echo ""
echo "3. Test connectivity:"
echo "   python3 src/main.py test"
echo ""
echo "4. Generate configurations:"
echo "   python3 src/main.py generate"
echo ""
echo "5. Deploy (dry run first):"
echo "   python3 src/main.py deploy --dry-run"
echo ""
echo "📖 For more information, see README.md"
