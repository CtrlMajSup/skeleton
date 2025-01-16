#!/bin/bash

# Couleurs pour la sortie
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'  # No Color

# Fonction d'affichage du message d'aide
help() {
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                   CHECK-TEMPLATE HELP                    ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo -e "${CYAN}Description:${NC}"
    echo -e "  Ce script vérifie l'intégrité du template du projet en vérifiant les fichiers et les permissions."
    echo -e "${GREEN}Usage: ./check-template.sh${NC}"
    exit 0
}

# Vérification des permissions et types de fichiers dans le répertoire "scripts"
check_scripts() {
    echo -e "${BLUE}Vérification du répertoire ${GREEN}scripts${NC}..."

    for file in "$PROJECT_ROOT/scripts"/*; do
        # Ignorer les fichiers README
        if [[ "$file" =~ README.md$ ]]; then
            continue
        fi

        # Vérifier les fichiers exécutables (les scripts doivent être exécutables)
        if [ ! -x "$file" ]; then
            echo -e "${RED}[ERREUR] Le fichier $file n'est pas exécutable.${NC}"
        fi

        # Vérifier les fichiers autres que .sh
        if [[ ! "$file" =~ \.sh$ ]]; then
            echo -e "${YELLOW}[ATTENTION] Le fichier $file n'est pas un fichier .sh.${NC}"
        fi
    done
}

# Vérification des fichiers dans "traits"
check_traits() {
    echo -e "${BLUE}Vérification du répertoire ${GREEN}traits${NC}..."

    for file in "$PROJECT_ROOT/traits"/*; do
        # Ignorer les fichiers README
        if [[ "$file" =~ README.md$ ]]; then
            continue
        fi

        # Vérifier les fichiers sans _
        if [[ ! "$file" =~ _ ]]; then
            echo -e "${RED}[ERREUR] Le fichier $file dans traits n'a pas de _ (excepté README.md).${NC}"
        fi
    done
}

# Vérification des fichiers dans "backups"
check_backups() {
    echo -e "${BLUE}Vérification du répertoire ${GREEN}backups${NC}..."

    for file in "$PROJECT_ROOT/backups"/*; do
        # Ignorer les fichiers README
        if [[ "$file" =~ README.md$ ]]; then
            continue
        fi

        # Vérifier que le fichier est un fichier .tar.gz
        if [[ ! "$file" =~ \.tar\.gz$ ]]; then
            echo -e "${RED}[ERREUR] Le fichier $file dans backups n'est pas un fichier .tar.gz.${NC}"
        fi
    done
}

# Analyser les options
while [[ "$1" != "" ]]; do
    case $1 in
        -h | --help )          help
                               ;;
        * )                    help
                               ;;
    esac
    shift
done

# Définir la racine du projet
PROJECT_ROOT=$(realpath "$(dirname "$(realpath "$0")")/..")

# Vérifications
echo -e "${GREEN}Vérification de l'intégrité du template du projet...${NC}"

check_scripts
check_traits
check_backups

echo -e "${GREEN}Vérification terminée.${NC}"
