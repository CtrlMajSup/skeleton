#!/bin/bash

# Couleurs pour la sortie
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'  # No Color

# Variables à configurer
SCRIPT_DIR=$(dirname "$(realpath "$0")")  # Répertoire où se trouve le script (./scripts)
PROJECT_ROOT=$(realpath "$SCRIPT_DIR/..")  # Racine du projet (le dossier parent de ./scripts)
OUTPUT_DIR="$PROJECT_ROOT/backups"  # Le dossier de sauvegarde est relatif à la racine du projet

# Options
VERBOSE=0
DRY_RUN=0

# Fonction d'affichage de l'aide
help() {
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                   RESTORE-BACKUP HELP                   ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo -e "${CYAN}Description:${NC}"
    echo -e "  Ce script permet de restaurer une archive de backup à partir du répertoire des sauvegardes."
    echo -e "${GREEN}Usage: ./restore-backup.sh [options]${NC}"
    echo -e "${YELLOW}Options:${NC}"
    echo -e "  -h, --help        Affiche l'aide"
    echo -e "  -v, --verbose     Mode verbose (affiche plus d'informations)"
    echo -e "  -d, --dry-run     Mode dry-run (simule la restauration, ne fait rien)"
    echo -e "${GREEN}Exemple d'utilisation :${NC}"
    echo -e "  ./restore-backup.sh -v"
    exit 0
}

# Analyser les options
while [[ "$1" != "" ]]; do
    case $1 in
        -h | --help )          help
                               ;;
        -v | --verbose )       VERBOSE=1
                               ;;
        -d | --dry-run )       DRY_RUN=1
                               ;;
        * )                    help
                               ;;
    esac
    shift
done

# Vérifier si le répertoire de sauvegarde existe
if [ ! -d "$OUTPUT_DIR" ]; then
    echo -e "${RED}Erreur : Le répertoire de sauvegarde $OUTPUT_DIR n'existe pas.${NC}"
    exit 1
fi

# Lister les archives disponibles dans le répertoire de sauvegarde
echo -e "${YELLOW}Archives disponibles :${NC}"
ARCHIVES=($(ls "$OUTPUT_DIR"/*.tar.gz))
if [ ${#ARCHIVES[@]} -eq 0 ]; then
    echo -e "${RED}Aucune archive trouvée dans $OUTPUT_DIR.${NC}"
    exit 1
fi

# Afficher les archives et demander à l'utilisateur de choisir
select ARCHIVE in "${ARCHIVES[@]}"; do
    if [ -n "$ARCHIVE" ]; then
        echo -e "${GREEN}Vous avez choisi l'archive : $ARCHIVE${NC}"
        break
    else
        echo -e "${RED}Choix invalide. Essayez de nouveau.${NC}"
    fi
done

# Mode Dry-run (simulation)
if [ $DRY_RUN -eq 1 ]; then
    echo -e "${YELLOW}Mode dry-run activé. Aucune restauration ne sera effectuée.${NC}"
    echo -e "Voici ce qui serait exécuté :"
    echo -e "  tar -xzf $ARCHIVE -C $PROJECT_ROOT"
    exit 0
fi

# Mode verbose (affiche chaque étape)
if [ $VERBOSE -eq 1 ]; then
    echo -e "${YELLOW}Mode verbose activé.${NC}"
    echo -e "Restaurer l'archive $ARCHIVE dans le répertoire $PROJECT_ROOT"
fi

# Extraire l'archive
if [ $VERBOSE -eq 1 ]; then
    echo -e "${GREEN}Extraction de l'archive...${NC}"
fi
tar -xzf "$ARCHIVE" -C / # "$PROJECT_ROOT"

# Vérification du succès de l'opération
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Restauration terminée avec succès.${NC}"
else
    echo -e "${RED}Erreur lors de l'extraction de l'archive.${NC}"
    exit 1
fi
