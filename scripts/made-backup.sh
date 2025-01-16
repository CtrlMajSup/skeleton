#!/bin/bash

# Couleurs pour la sortie
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'  # No Color

# Variables à configurer
# Variables à configurer
SCRIPT_DIR=$(dirname "$(realpath "$0")")  # Répertoire où se trouve le script (./scripts)
PROJECT_ROOT=$(realpath "$SCRIPT_DIR/..")  # Racine du projet (le dossier parent de ./scripts)
OUTPUT_DIR="$PROJECT_ROOT/backups"  # Le dossier de sauvegarde est relatif à la racine du projet
SOURCE_DIRS=("$PROJECT_ROOT/instances/natives/example/" "$PROJECT_ROOT/traits")  # Répertoires à sauvegarder (exemples)


# Options
VERBOSE=0
DRY_RUN=0

# Fonction d'affichage de l'aide
help() {
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                   MADE-BACKUP HELP                    ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo -e "${CYAN}Description:${NC}"
    echo -e "  Ce script de backup des dossiers renseigner dans SOURCE_DIRS"
    echo -e "${GREEN}Usage: ./backup.sh [options]${NC}"
    echo -e "${YELLOW}Options:${NC}"
    echo -e "  -h, --help        Affiche l'aide"
    echo -e "  -v, --verbose     Mode verbose (affiche plus d'informations)"
    echo -e "  -d, --dry-run     Mode dry-run (simule le backup, ne fait rien)"
    echo -e "  -o, --output      Répertoire de sortie pour l'archive"
    echo -e "  -s, --sources     Liste des répertoires à sauvegarder (séparés par espace)"
    echo -e "${GREEN}Exemple d'utilisation :${NC}"
    echo -e "  ./backup.sh -o /backups -s /home/user/data /home/user/docs -v"
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
        -o | --output )        shift
                               OUTPUT_DIR=$1
                               ;;
        -s | --sources )       shift
                               SOURCE_DIRS=($@)
                               break
                               ;;
        * )                    help
                               ;;
    esac
    shift
done

# Vérifier si le répertoire de sortie existe
if [ ! -d "$OUTPUT_DIR" ]; then
    echo -e "${RED}Erreur : Le répertoire de sortie $OUTPUT_DIR n'existe pas.${NC}"
    exit 1
fi

# Générer le nom de l'archive avec la date actuelle
DATE=$(date +%Y-%m-%d_%H-%M-%S)
ARCHIVE_NAME="backup_$DATE.tar.gz"
ARCHIVE_PATH="$OUTPUT_DIR/$ARCHIVE_NAME"

# Afficher un message de début
echo -e "${GREEN}Démarrage du backup...${NC}"
echo -e "${YELLOW}Sauvegarde des répertoires suivants :${NC}"
for DIR in "${SOURCE_DIRS[@]}"; do
    echo -e "  - $DIR"
done

# Mode Dry-run (simulation)
if [ $DRY_RUN -eq 1 ]; then
    echo -e "${YELLOW}Mode dry-run activé. Aucune archive ne sera créée.${NC}"
    echo -e "Voici ce qui serait exécuté :"
    echo -e "  tar -czf $ARCHIVE_PATH ${SOURCE_DIRS[@]}"
    exit 0
fi

# Mode verbose (affiche chaque étape)
if [ $VERBOSE -eq 1 ]; then
    echo -e "${YELLOW}Mode verbose activé.${NC}"
    echo -e "Création de l'archive : $ARCHIVE_PATH"
fi

# Exécuter le backup
if [ $VERBOSE -eq 1 ]; then
    echo -e "${GREEN}Création de l'archive...${NC}"
fi
tar -czf "$ARCHIVE_PATH" "${SOURCE_DIRS[@]}"

# Vérification du succès de l'opération
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Sauvegarde terminée avec succès : $ARCHIVE_PATH${NC}"
else
    echo -e "${RED}Erreur lors de la création de l'archive.${NC}"
    exit 1
fi
