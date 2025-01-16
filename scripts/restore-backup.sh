#!/bin/bash

# Couleurs pour la sortie
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'  # No Color

# Variables à configurer
SCRIPT_DIR=$(dirname "$(realpath "$0")")
PROJECT_ROOT=$(realpath "$SCRIPT_DIR/..")
OUTPUT_DIR="$PROJECT_ROOT/backups"
LOGS_DIR="$PROJECT_ROOT/events"
LOG_FILE="$LOGS_DIR/restore-backup_$(date +%Y-%m-%d_%H-%M-%S).log"

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
    echo -e "${BLUE}║                   RESTORE-BACKUP HELP                      ║${NC}"
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
        * )                    help ;;
    esac
    shift
done

# Vérifier si le répertoire de sauvegarde existe
if [ ! -d "$OUTPUT_DIR" ]; then
    error "Le répertoire de sauvegarde $OUTPUT_DIR n'existe pas."
    exit 1
fi

# Lister les archives disponibles
info "Recherche des archives disponibles..."
ARCHIVES=($(ls "$OUTPUT_DIR"/*.tar.gz))
if [ ${#ARCHIVES[@]} -eq 0 ]; then
    error "Aucune archive trouvée dans $OUTPUT_DIR"
    exit 1
fi

# Afficher les archives disponibles
info "Archives disponibles :"
select ARCHIVE in "${ARCHIVES[@]}"; do
    if [ -n "$ARCHIVE" ]; then
        verbose "Archive sélectionnée : $ARCHIVE"
        break
    else
        error "Choix invalide. Essayez de nouveau."
    fi
done

# Mode Dry-run
if [ "$DRY_RUN" = true ]; then
    info "Simulation de la commande: tar -xzf $ARCHIVE -C $PROJECT_ROOT"
    exit 0
fi

# Extraire l'archive
verbose "Démarrage de la restauration depuis : $ARCHIVE"
verbose "Destination : $PROJECT_ROOT"

tar -xzf "$ARCHIVE" -C / 2>> "$LOG_FILE"

# Vérification du résultat
if [ $? -eq 0 ]; then
    success "Restauration terminée avec succès"
    ARCHIVE_SIZE=$(du -h "$ARCHIVE" | cut -f1)
    info "Taille de l'archive restaurée : $ARCHIVE_SIZE"
else
    error "Échec de la restauration de l'archive"
    exit 1
fi
