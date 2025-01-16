#!/bin/bash

# Couleurs pour la sortie
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'  # No Color

# Variables à configurer
SCRIPT_DIR=$(dirname "$(realpath "$0")")
PROJECT_ROOT=$(realpath "$SCRIPT_DIR/..")
OUTPUT_DIR="$PROJECT_ROOT/backups"
SOURCE_DIRS=("$PROJECT_ROOT/instances/natives/example/" "$PROJECT_ROOT/traits")
LOGS_DIR="$PROJECT_ROOT/events"
LOG_FILE="$LOGS_DIR/backup_$(date +%Y-%m-%d_%H-%M-%S).log"

# Options
VERBOSE=false
DRY_RUN=false

# Fonction pour écrire dans les logs
log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${timestamp} [${level}] ${message}" >> "$LOG_FILE"
}

# Fonction pour afficher les messages d'erreur
error() {
    echo -e "${RED}[ERREUR]${NC} $1" >&2
    log "ERROR" "$1"
}

# Fonction pour afficher les messages d'information
info() {
    echo -e "${BLUE}[INFO]${NC} $1"
    log "INFO" "$1"
}

# Fonction pour afficher les messages de succès
success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
    log "SUCCESS" "$1"
}

# Fonction pour afficher les messages en mode verbose
verbose() {
    if [ "$VERBOSE" = true ]; then
        echo -e "${PURPLE}[VERBOSE]${NC} $1"
        log "VERBOSE" "$1"
    fi
}

# Fonction d'affichage de l'aide
help() {
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                   MADE-BACKUP HELP                         ║${NC}"
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

# Création du répertoire de logs si nécessaire
if [ ! -d "$LOGS_DIR" ]; then
    mkdir -p "$LOGS_DIR"
    if [ $? -ne 0 ]; then
        error "Impossible de créer le répertoire de logs"
        exit 1
    fi
fi

# Analyser les options
while [[ "$1" != "" ]]; do
    case $1 in
        -h | --help )          help ;;
        -v | --verbose )       VERBOSE=true
                              verbose "Mode verbose activé" ;;
        -d | --dry-run )       DRY_RUN=true
                              info "Mode dry-run activé" ;;
        -o | --output )        shift
                              OUTPUT_DIR=$1
                              verbose "Répertoire de sortie défini: $OUTPUT_DIR" ;;
        -s | --sources )       shift
                              SOURCE_DIRS=($@)
                              verbose "Sources définies: ${SOURCE_DIRS[*]}"
                              break ;;
        * )                    help ;;
    esac
    shift
done

# Vérifier si le répertoire de sortie existe
if [ ! -d "$OUTPUT_DIR" ]; then
    error "Le répertoire de sortie $OUTPUT_DIR n'existe pas."
    exit 1
fi

# Générer le nom de l'archive
DATE=$(date +%Y-%m-%d_%H-%M-%S)
ARCHIVE_NAME="backup_$DATE.tar.gz"
ARCHIVE_PATH="$OUTPUT_DIR/$ARCHIVE_NAME"

# Logger les informations de démarrage
info "Démarrage du backup..."
verbose "Sources à sauvegarder:"
for DIR in "${SOURCE_DIRS[@]}"; do
    verbose "  - $DIR"
done

# Mode Dry-run
if [ "$DRY_RUN" = true ]; then
    info "Simulation de la commande: tar -czf $ARCHIVE_PATH ${SOURCE_DIRS[*]}"
    exit 0
fi

# Créer le backup
verbose "Création de l'archive: $ARCHIVE_PATH"
tar -czf "$ARCHIVE_PATH" "${SOURCE_DIRS[@]}" 2>> "$LOG_FILE"

# Vérification du résultat
if [ $? -eq 0 ]; then
    success "Sauvegarde terminée avec succès: $ARCHIVE_PATH"
    ARCHIVE_SIZE=$(du -h "$ARCHIVE_PATH" | cut -f1)
    info "Taille de l'archive: $ARCHIVE_SIZE"
else
    error "Échec de la création de l'archive"
    exit 1
fi
