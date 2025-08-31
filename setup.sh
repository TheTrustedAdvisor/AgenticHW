#!/bin/bash
# Setup script for Huawei Network Automation Suite - Phase 1

set -e

echo "🚀 Setting up Huawei Network Automation Suite - Phase 1"
echo "=================================================="

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

# Check required packages
echo "📦 Checking Python packages..."
if pip3 show napalm netmiko jinja2 pyyaml pytest ansible paramiko textfsm cerberus > /dev/null 2>&1; then
    echo "✅ All required packages are installed"
else
    echo "📦 Installing required packages..."
    pip3 install -r requirements.txt
    echo "✅ Packages installed successfully"
fi

# Create output directory
echo "📁 Creating output directories..."
mkdir -p src/automation/huawei/configs
echo "✅ Output directories created"

# Check environment variables
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
