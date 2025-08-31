#!/bin/bash
# Live Demo Script für Huawei Network Automation Suite - Phase 1
# Führt eine vollständige Demo durch

set -e

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "🚀 Huawei Network Automation Suite - Phase 1"
echo "=================================================="
echo "Vollautomatisiertes Netzwerk-Management Demo"
echo -e "${NC}"

# Prüfe Virtual Environment
if [[ "$VIRTUAL_ENV" == "" ]]; then
    echo -e "${YELLOW}⚠️  Aktiviere Virtual Environment...${NC}"
    source .venv/bin/activate
fi

echo -e "${BLUE}📋 Schritt 1: Umgebung validieren${NC}"
echo "Prüfe Projektstruktur, Templates und Dependencies..."
PYTHONPATH=. python src/automation/huawei/scripts/core/phase1_deployer.py --validate
echo -e "${GREEN}✅ Umgebung validiert${NC}"
echo ""

echo -e "${BLUE}🧪 Schritt 2: Test-Suite ausführen${NC}"
echo "Führe 24 Unit- und Integrationstests durch..."
PYTHONPATH=. python -m pytest tests/ -q --tb=no
echo -e "${GREEN}✅ Alle Tests erfolgreich${NC}"
echo ""

echo -e "${BLUE}⚙️ Schritt 3: Konfigurationen generieren${NC}"
echo "Generiere Huawei CLI-Konfigurationen für alle 6 Geräte..."
PYTHONPATH=. python src/automation/huawei/scripts/core/phase1_deployer.py --generate
echo -e "${GREEN}✅ Konfigurationen generiert${NC}"
echo ""

echo -e "${BLUE}📊 Schritt 4: Deployment-Plan anzeigen${NC}"
echo "Zeige sequentielle Deployment-Reihenfolge..."
PYTHONPATH=. python src/automation/huawei/scripts/core/phase1_deployer.py --dry-run

echo ""
echo -e "${GREEN}🎉 Demo erfolgreich abgeschlossen!${NC}"
echo ""
echo -e "${YELLOW}📁 Generierte Dateien:${NC}"
echo "$(ls -la src/automation/huawei/configs/*.cfg | wc -l | tr -d ' ') Konfigurationsdateien in src/automation/huawei/configs/"
echo ""
echo -e "${YELLOW}🔗 Nächste Schritte:${NC}"
echo "• Für Live-Deployment: IP-Adressen in inventory.yaml anpassen"
echo "• SSH-Keys konfigurieren: ssh-keygen -t rsa -b 4096"
echo "• Connectivity testen: --connectivity Flag nutzen"
echo "• Phase 2: Advanced Features (BGP, Self-Healing, Chaos Engineering)"
echo ""
echo -e "${BLUE}📚 Dokumentation: siehe deployment_standards.md${NC}"
