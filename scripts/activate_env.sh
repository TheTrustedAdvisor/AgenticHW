#!/bin/bash
# Huawei Network Automation Suite - Environment Activation
cd "$(dirname "$0")/.."  # Navigate to project root
source .venv/bin/activate
echo "🚀 Huawei Network Automation Suite environment activated!"
echo "📋 Available commands:"
echo "   • python demo_automation.py  # Run full demo"
echo "   • ./scripts/reset.sh         # Reset environment"
echo "   • deactivate                 # Exit virtual environment"
