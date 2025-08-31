#!/bin/bash

# Complete Reset Script füecho -e "${YELLOW}Folgende Verzeichnisse/Dateien werden KOMPLETT GELÖSCHT:# 4. Requirements.txt löschen
echo -e "${YELLOW}📦 Lösche Dependencies...$# 8. Temporäre & Backup Dateien löschen
echo -e "${YELLOW}🗑️  Lösche temporäre & Backup Dateien...${NC}"C}"
if [ -f "requirements.txt" ]; then
    rm -f requirements.txt
    echo -e "${GREEN}   ✓ requirements.txt gelöscht${NC}"
    deleted_count=$((deleted_count + 1))
else
    echo -e "${YELLOW}   • requirements.txt nicht gefunden${NC}"
fi

# 5. Python Cache komplett löschen "🗂️  src/automation/huawei/ (Komplettes Projektverzeichnis)"
echo "🧪 tests/ (Alle Test-Dateien)"
echo "📚 docs/ (Technische Dokumentation - wird aus deployment_standards.md rekonstruiert)"
echo "📦 requirements.txt (Dependencies)"
echo "🐍 __pycache__/, *.pyc, *.pyo (Python Cache)"
echo "🔬 .pytest_cache/, .coverage*, htmlcov/ (Test Cache)"
echo "📋 *.log, *.tmp, *.bak (Temporäre Dateien)"
echo ""
echo -e "${GREEN}Was BLEIBT ERHALTEN:${NC}"
echo "📄 deployment_standards.md (MASTER-Dokumentation für Rekonstruktion)"
echo "📋 Requirements.md (Projekt-Anforderungen)"
echo "🐍 .venv/ (Virtual Environment)"
echo "📄 demo.sh, reset.sh (Management Scripts)"
echo "🌐 .git/ (Git Repository)"rk Automation Suite
# Löscht ALLES und ermöglicht komplette Projekt-Rekonstruktion aus deployment_standards.md

# Farben für bessere Lesbarkeit
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${BLUE}============================================================${NC}"
echo -e "${BLUE}🏗️  COMPLETE RESET: Infrastructure as Code${NC}"
echo -e "${BLUE}Huawei Network Automation Suite - Total Cleanup${NC}"
echo -e "${BLUE}============================================================${NC}"
echo ""

# Funktion für Bestätigung
confirm() {
    read -p "$(echo -e ${YELLOW}$1${NC}) [y/N]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        return 0
    else
        return 1
    fi
}

# Warnung anzeigen
echo -e "${RED}⚠️  WARNUNG: KOMPLETTER PROJECT RESET!${NC}"
echo -e "${RED}Dieses Script löscht ALLE generierten Projektdateien!${NC}"
echo ""
echo -e "${PURPLE}📋 Infrastructure as Code Prinzip:${NC}"
echo "• Alle Komponenten werden aus deployment_standards.md rekonstruierbar"
echo "• Echter 'Clean Slate' für kompletten Neuaufbau"
echo "• Nur Dokumentation und .venv bleiben erhalten"
echo ""
echo -e "${YELLOW}Folgende Verzeichnisse/Dateien werden KOMPLETT GELÖSCHT:${NC}"
echo "🗂️  src/automation/huawei/ (Komplettes Projektverzeichnis)"
echo "🧪 tests/ (Alle Test-Dateien)"
echo "📦 requirements.txt (Dependencies)"
echo "🐍 __pycache__/, *.pyc, *.pyo (Python Cache)"
echo "🔬 .pytest_cache/, .coverage*, htmlcov/ (Test Cache)"
echo "📋 *.log, *.tmp, *.bak (Temporäre Dateien)"
echo ""
echo -e "${GREEN}Was BLEIBT ERHALTEN:${NC}"
echo "📚 *.md Dateien (Dokumentation)"
echo "� docs/ (Technische Dokumentation mit Mermaid-Diagrammen)"
echo "�🐍 .venv/ (Virtual Environment)"
echo "📄 demo.sh, reset.sh (Management Scripts)"
echo "🌐 .git/ (Git Repository)"
echo ""

if ! confirm "🚨 Möchten Sie WIRKLICH das komplette Projekt zurücksetzen?"; then
    echo -e "${YELLOW}Reset abgebrochen.${NC}"
    echo ""
    echo -e "${BLUE}💡 Alternative: Verwenden Sie das alte reset.sh für partielles Cleanup${NC}"
    exit 0
fi

echo ""
echo -e "${BLUE}🧹 Starte KOMPLETTES Projekt-Reset...${NC}"
echo ""

# Zähler für gelöschte Elemente
deleted_count=0

# 1. Hauptprojektverzeichnis löschen
echo -e "${YELLOW}�️  Lösche Hauptprojektverzeichnis...${NC}"
if [ -d "src" ]; then
    rm -rf src/
    echo -e "${GREEN}   ✓ src/ Verzeichnis komplett gelöscht${NC}"
    deleted_count=$((deleted_count + 1))
else
    echo -e "${YELLOW}   • src/ Verzeichnis nicht gefunden${NC}"
fi

# 2. Test-Verzeichnis löschen
echo -e "${YELLOW}🧪 Lösche Test-Verzeichnis...${NC}"
if [ -d "tests" ]; then
    rm -rf tests/
    echo -e "${GREEN}   ✓ tests/ Verzeichnis komplett gelöscht${NC}"
    deleted_count=$((deleted_count + 1))
else
    echo -e "${YELLOW}   • tests/ Verzeichnis nicht gefunden${NC}"
fi

# 3. Dokumentations-Verzeichnis löschen
echo -e "${YELLOW}📚 Lösche Dokumentations-Verzeichnis...${NC}"
if [ -d "docs" ]; then
    rm -rf docs/
    echo -e "${GREEN}   ✓ docs/ Verzeichnis komplett gelöscht${NC}"
    deleted_count=$((deleted_count + 1))
else
    echo -e "${YELLOW}   • docs/ Verzeichnis nicht gefunden${NC}"
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

# 4. Python Cache komplett löschen
echo -e "${YELLOW}🐍 Lösche Python Cache (rekursiv)...${NC}"

# __pycache__ Ordner
pycache_dirs=$(find . -type d -name "__pycache__" -not -path "./.venv/*" 2>/dev/null | wc -l)
if [ $pycache_dirs -gt 0 ]; then
    find . -type d -name "__pycache__" -not -path "./.venv/*" -exec rm -rf {} + 2>/dev/null
    echo -e "${GREEN}   ✓ $pycache_dirs __pycache__ Ordner gelöscht${NC}"
    deleted_count=$((deleted_count + pycache_dirs))
else
    echo -e "${YELLOW}   • Keine __pycache__ Ordner gefunden${NC}"
fi

# .pyc/.pyo Dateien
pyc_files=$(find . -name "*.pyc" -o -name "*.pyo" -not -path "./.venv/*" 2>/dev/null | wc -l)
if [ $pyc_files -gt 0 ]; then
    find . -name "*.pyc" -o -name "*.pyo" -not -path "./.venv/*" -delete
    echo -e "${GREEN}   ✓ $pyc_files Python Bytecode Dateien gelöscht${NC}"
    deleted_count=$((deleted_count + pyc_files))
else
    echo -e "${YELLOW}   • Keine .pyc/.pyo Dateien gefunden${NC}"
fi

# 6. Test & Coverage Cache löschen
echo -e "${YELLOW}🔬 Lösche Test & Coverage Cache...${NC}"

# .pytest_cache
if [ -d ".pytest_cache" ]; then
    rm -rf .pytest_cache
    echo -e "${GREEN}   ✓ .pytest_cache Ordner gelöscht${NC}"
    deleted_count=$((deleted_count + 1))
fi

# Coverage Dateien
coverage_files=$(find . -name ".coverage*" -not -path "./.venv/*" 2>/dev/null | wc -l)
if [ $coverage_files -gt 0 ]; then
    find . -name ".coverage*" -not -path "./.venv/*" -delete
    echo -e "${GREEN}   ✓ $coverage_files Coverage Dateien gelöscht${NC}"
    deleted_count=$((deleted_count + coverage_files))
fi

# htmlcov
if [ -d "htmlcov" ]; then
    rm -rf htmlcov
    echo -e "${GREEN}   ✓ htmlcov Ordner gelöscht${NC}"
    deleted_count=$((deleted_count + 1))
fi

# .tox
if [ -d ".tox" ]; then
    rm -rf .tox
    echo -e "${GREEN}   ✓ .tox Ordner gelöscht${NC}"
    deleted_count=$((deleted_count + 1))
fi

# 6. Temporäre & Backup Dateien löschen
echo -e "${YELLOW}�️  Lösche temporäre & Backup Dateien...${NC}"
temp_files=$(find . -name "*.log" -o -name "*.tmp" -o -name "*.bak" -o -name "*~" -o -name "*.swp" -not -path "./.venv/*" -not -path "./.git/*" 2>/dev/null | wc -l)
if [ $temp_files -gt 0 ]; then
    find . -name "*.log" -o -name "*.tmp" -o -name "*.bak" -o -name "*~" -o -name "*.swp" -not -path "./.venv/*" -not -path "./.git/*" -delete
    echo -e "${GREEN}   ✓ $temp_files temporäre/Backup Dateien gelöscht${NC}"
    deleted_count=$((deleted_count + temp_files))
else
    echo -e "${YELLOW}   • Keine temporären Dateien gefunden${NC}"
fi

echo ""
echo -e "${BLUE}============================================================${NC}"
echo -e "${GREEN}✅ KOMPLETTER RESET ERFOLGREICH ABGESCHLOSSEN!${NC}"
echo ""
echo -e "${GREEN}📊 Zusammenfassung:${NC}"
echo -e "   • Insgesamt $deleted_count Dateien/Ordner gelöscht"
echo -e "   • Projekt komplett auf 'Clean Slate' zurückgesetzt"
echo -e "   • Bereit für vollständige Rekonstruktion"
echo ""
echo -e "${BLUE}🏗️  Infrastructure as Code - Rekonstruktion:${NC}"
echo -e "   1. ${GREEN}Lesen Sie deployment_standards.md${NC} für vollständige Anweisungen"
echo -e "   2. ${GREEN}Alle Komponenten${NC} können aus der Dokumentation rekonstruiert werden"
echo -e "   3. ${GREEN}docs/ Verzeichnis${NC} wird aus deployment_standards.md neu erstellt"
echo -e "   4. ${GREEN}Virtual Environment (.venv)${NC} bleibt für Dependencies erhalten"
echo -e "   5. ${GREEN}Git Repository${NC} und Master-Dokumentation unverändert"
echo ""
echo -e "${PURPLE}� Nächste Schritte:${NC}"
echo -e "   • Befolgen Sie die Rekonstruktions-Schritte in deployment_standards.md"
echo -e "   • Erstellen Sie Projektstruktur, Module, Templates und Tests neu"
echo -e "   • Führen Sie ./demo.sh aus für vollständige Demo"
echo ""
echo -e "${YELLOW}💡 Dies ist echtes 'Infrastructure as Code' - alles aus Dokumentation reproduzierbar!${NC}"
echo -e "${BLUE}============================================================${NC}"
