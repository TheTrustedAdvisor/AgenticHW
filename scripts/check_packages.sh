#!/bin/bash

# Package Check Utility for Huawei Network Automation Suite
# This script checks if all required packages are installed and working

echo "🔍 Checking installed packages..."

# Check if virtual environment is active
if [ -z "$VIRTUAL_ENV" ]; then
    echo "❌ Virtual environment not active"
    echo "💡 Run: source scripts/activate_env.sh"
    exit 1
fi

echo "✅ Virtual environment active: $VIRTUAL_ENV"
echo ""

# Check core packages
PACKAGES=(
    "netmiko:netmiko"
    "jinja2:jinja2" 
    "yaml:PyYAML"
    "pytest:pytest"
    "ansible:ansible"
    "paramiko:paramiko"
    "textfsm:textfsm"
    "cerberus:cerberus"
)

ALL_GOOD=true

for package_info in "${PACKAGES[@]}"; do
    IFS=':' read -r import_name package_name <<< "$package_info"
    
    printf "%-15s " "$package_name:"
    
    if python -c "import $import_name; print(f'✅ {$import_name.__version__ if hasattr($import_name, \"__version__\") else \"installed\"}')" 2>/dev/null; then
        # Package is installed and working
        :
    else
        echo "❌ NOT INSTALLED"
        ALL_GOOD=false
    fi
done

echo ""

if [ "$ALL_GOOD" = true ]; then
    echo "🎉 All packages are installed and working!"
    echo "🚀 Ready to run: python demo_automation.py"
else
    echo "⚠️  Some packages are missing"
    echo "💡 Run: ./scripts/setup.sh"
fi
