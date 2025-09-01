#!/bin/bash

# Complete Reset Script for Huawei Network Automation Suite - Phase 1

# Change to project root directory (parent of scripts/)
cd "$(dirname "$0")/.."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}============================================================${NC}"
echo -e "${BLUE}🏗️  COMPLETE RESET: Infrastructure as Code${NC}"
echo -e "${BLUE}Huawei Network Automation Suite - Total Cleanup${NC}"
echo -e "${BLUE}============================================================${NC}"
echo ""

# Function for confirmation
confirm() {
    read -p "$(echo -e ${YELLOW}$1${NC}) [y/N]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        return 0
    else
        return 1
    fi
}

# Warning
echo -e "${RED}⚠️  WARNUNG: KOMPLETTER PROJECT RESET!${NC}"
echo -e "${RED}Dieses Script löscht ALLE generierten Projektdateien!${NC}"
echo ""

echo -e "${YELLOW}Folgende Verzeichnisse/Dateien werden KOMPLETT GELÖSCHT:${NC}"
echo "🗂️  src/ (Komplettes Projektverzeichnis)"
echo "🧪 tests/ (Alle Test-Dateien)" 
echo "📚 docs/ (Technische Dokumentation)"
echo "📦 requirements.txt (Dependencies)"
echo "🐍 __pycache__/, *.pyc, *.pyo (Python Cache)"
echo "🔬 .pytest_cache/, .coverage* (Test Cache)"
echo "📋 *.log, *.tmp, *.bak (Temporäre Dateien)"
echo ""

echo -e "${GREEN}Was BLEIBT ERHALTEN:${NC}"
echo "📄 documentation/ (Standards & Spezifikationen)"
echo "📋 Requirements.md (Projekt-Anforderungen)"
echo "🐍 .venv/ (Virtual Environment) - WIRD BEWAHRT FÜR VSCODE STABILITÄT"
echo "📄 scripts/ (Management Scripts)"
echo "🌐 .git/ (Git Repository)"
echo ""

if ! confirm "Möchten Sie wirklich ALLE Projektdateien löschen?"; then
    echo -e "${YELLOW}Reset abgebrochen.${NC}"
    exit 0
fi

deleted_count=0

# 1. Source Code löschen
echo -e "${YELLOW}🗂️  Lösche Source Code...${NC}"
if [ -d "src" ]; then
    rm -rf src/
    echo -e "${GREEN}   ✓ src/ gelöscht${NC}"
    deleted_count=$((deleted_count + 1))
else
    echo -e "${YELLOW}   • src/ nicht gefunden${NC}"
fi

# 2. Tests löschen
echo -e "${YELLOW}🧪 Lösche Tests...${NC}"
if [ -d "tests" ]; then
    rm -rf tests/
    echo -e "${GREEN}   ✓ tests/ gelöscht${NC}"
    deleted_count=$((deleted_count + 1))
else
    echo -e "${YELLOW}   • tests/ nicht gefunden${NC}"
fi

# 3. Documentation löschen
echo -e "${YELLOW}📚 Lösche docs/...${NC}"
if [ -d "docs" ]; then
    rm -rf docs/
    echo -e "${GREEN}   ✓ docs/ gelöscht${NC}"
    deleted_count=$((deleted_count + 1))
else
    echo -e "${YELLOW}   • docs/ nicht gefunden${NC}"
fi

# 4. Requirements.txt löschen
echo -e "${YELLOW}📦 Lösche Dependencies...${NC}"
if [ -f "requirements.txt" ]; then
    rm -f requirements.txt
    echo -e "${GREEN}   ✓ requirements.txt gelöscht${NC}"
    deleted_count=$((deleted_count + 1))
else
    echo -e "${YELLOW}   • requirements.txt nicht gefunden${NC}"
fi

# 5. Python Cache komplett löschen
echo -e "${YELLOW}🐍 Lösche Python Cache...${NC}"
find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
find . -name "*.pyc" -delete 2>/dev/null || true
find . -name "*.pyo" -delete 2>/dev/null || true
echo -e "${GREEN}   ✓ Python Cache gelöscht${NC}"

# 6. Test Cache löschen
echo -e "${YELLOW}🔬 Lösche Test Cache...${NC}"
if [ -d ".pytest_cache" ]; then
    rm -rf .pytest_cache/
    echo -e "${GREEN}   ✓ .pytest_cache/ gelöscht${NC}"
    deleted_count=$((deleted_count + 1))
fi

find . -name ".coverage*" -delete 2>/dev/null || true
if [ -d "htmlcov" ]; then
    rm -rf htmlcov/
    echo -e "${GREEN}   ✓ htmlcov/ gelöscht${NC}"
fi

# 7. Temporäre & Backup Dateien löschen
echo -e "${YELLOW}🗑️  Lösche temporäre & Backup Dateien...${NC}"
find . -name "*.log" -delete 2>/dev/null || true
find . -name "*.tmp" -delete 2>/dev/null || true
find . -name "*.bak" -delete 2>/dev/null || true
find . -name "*~" -delete 2>/dev/null || true
echo -e "${GREEN}   ✓ Temporäre Dateien gelöscht${NC}"

# 8. Zusätzliche Cleanup-Tasks
echo -e "${YELLOW}🧹 Zusätzliche Cleanup-Tasks...${NC}"
# Remove any demo artifacts
find . -maxdepth 1 -name "*[*" -delete 2>/dev/null || true
echo -e "${GREEN}   ✓ Demo-Artefakte gelöscht${NC}"

echo ""
echo -e "${BLUE}============================================================${NC}"
echo -e "${GREEN}✅ RESET KOMPLETT! ${deleted_count} Hauptkomponenten gelöscht${NC}"
echo -e "${BLUE}============================================================${NC}"
echo ""
echo -e "${GREEN}📋 Nächste Schritte:${NC}"
echo "1. Führen Sie './setup' aus, um das Projekt neu zu erstellen"
echo "2. Das Setup rekonstruiert alles aus Requirements.md"
echo "3. Alle Core-Module werden automatisch generiert"
echo ""
echo -e "${YELLOW}💡 Tipp: Für schnelle Rekonstruktion verwenden Sie:${NC}"
echo "   ./setup && ./demo"
echo ""
