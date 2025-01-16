#!/bin/bash

# Couleurs pour la sortie
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'  # No Color

# Variables de configuration
SCRIPT_DIR=$(dirname "$(realpath "$0")")  # Répertoire où se trouve le script
PROJECT_ROOT=$(realpath "$SCRIPT_DIR/..")  # Racine du projet
DOCS_DIR="$PROJECT_ROOT/docs"  # Dossier contenant les documents à pousser
DEST_DIR="/home/guillaume/Bureau/pushed_docs"  # Dossier de destination
VERBOSE=0
DRY_RUN=0

# Fonction d'affichage de l'aide
help() {
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                   PUSH-DOCS HELP                         ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo -e "${CYAN}Description:${NC}"
    echo -e "  Ce script permet de copier les fichiers markdown du dossier docs vers un"
    echo -e "  dossier de destination en créant une structure avec le nom du projet et"
    echo -e "  le nom de la machine hôte."
    echo -e "${GREEN}Usage: ./push-docs.sh [options]${NC}"
    echo -e "${YELLOW}Options:${NC}"
    echo -e "  -h, --help        Affiche l'aide"
    echo -e "  -v, --verbose     Mode verbose (affiche plus d'informations)"
    echo -e "  -d, --dry-run     Mode dry-run (simule sans rien copier)"
    echo -e "${GREEN}Exemple d'utilisation :${NC}"
    echo -e "  ./push-docs.sh -v -d"
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

# Vérifier si le dossier docs existe
if [ ! -d "$DOCS_DIR" ]; then
    echo -e "${RED}Erreur : Le dossier $DOCS_DIR n'existe pas.${NC}"
    exit 1
fi

# Nom du projet et nom de la machine hôte
PROJECT_NAME=$(basename "$PROJECT_ROOT" | tr 'a-z' 'A-Z')  # Nom du projet en majuscules
HOSTNAME=$(hostname | tr 'a-z' 'A-Z')  # Nom de la machine hôte en majuscules

# Répertoire de destination final
FINAL_DEST_DIR="$DEST_DIR/$PROJECT_NAME/$HOSTNAME"
# FINAL_DEST_DIR="$DEST_DIR/$HOSTNAME/$PROJECT_NAME"

# Mode verbose
if [ $VERBOSE -eq 1 ]; then
    echo -e "${YELLOW}Mode verbose activé.${NC}"
    echo -e "Répertoire source : $DOCS_DIR"
    echo -e "Répertoire de destination final : $FINAL_DEST_DIR"
fi

# Créer les répertoires si ils n'existent pas
if [ $VERBOSE -eq 1 ]; then
    echo -e "${GREEN}Création des répertoires nécessaires...${NC}"
fi
mkdir -p "$FINAL_DEST_DIR"

# Mode dry-run (simulation)
if [ $DRY_RUN -eq 1 ]; then
    echo -e "${YELLOW}Mode dry-run activé. Aucune copie ne sera effectuée.${NC}"
    echo -e "Voici ce qui serait exécuté :"
    echo -e "  rsync -av --delete $DOCS_DIR/ $FINAL_DEST_DIR/"
    exit 0
fi

# Copier les fichiers avec rsync (si non dry-run)
if [ $VERBOSE -eq 1 ]; then
    echo -e "${GREEN}Copie des fichiers du dossier docs vers $FINAL_DEST_DIR...${NC}"
fi

rsync -av --delete "$DOCS_DIR/" "$FINAL_DEST_DIR/"

# Vérification du succès de la commande
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Documents copiés avec succès dans $FINAL_DEST_DIR.${NC}"
else
    echo -e "${RED}Erreur lors de la copie des documents.${NC}"
    exit 1
fi
