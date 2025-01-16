#!/bin/bash

# Couleurs pour la sortie
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'  # No Color

# Variables de configuration
SCRIPT_DIR=$(dirname "$(realpath "$0")")
PROJECT_ROOT=$(realpath "$SCRIPT_DIR/..")
DOCS_DIR="$PROJECT_ROOT/docs"
DEST_DIR="/home/guillaume/Bureau/pushed_docs"
LOGS_DIR="$PROJECT_ROOT/events"
LOG_FILE="$LOGS_DIR/push-docs_$(date +%Y-%m-%d_%H-%M-%S).log"

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
    echo -e "${BLUE}║                   PUSH-DOCS HELP                           ║${NC}"
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

# Vérifier si le dossier docs existe
if [ ! -d "$DOCS_DIR" ]; then
    error "Le dossier $DOCS_DIR n'existe pas"
    exit 1
fi

# Nom du projet et nom de la machine hôte
PROJECT_NAME=$(basename "$PROJECT_ROOT" | tr 'a-z' 'A-Z')
HOSTNAME=$(hostname | tr 'a-z' 'A-Z')
FINAL_DEST_DIR="$DEST_DIR/$PROJECT_NAME/$HOSTNAME"
# FINAL_DEST_DIR="$DEST_DIR/$HOSTNAME/$PROJECT_NAME"

verbose "Configuration:"
verbose "- Répertoire source : $DOCS_DIR"
verbose "- Répertoire de destination : $FINAL_DEST_DIR"
verbose "- Nom du projet : $PROJECT_NAME"
verbose "- Nom de l'hôte : $HOSTNAME"

# Créer les répertoires si ils n'existent pas
info "Création des répertoires nécessaires..."
if [ "$DRY_RUN" = false ]; then
    mkdir -p "$FINAL_DEST_DIR"
    if [ $? -ne 0 ]; then
        error "Impossible de créer le répertoire de destination"
        exit 1
    fi
    success "Répertoires créés avec succès"
else
    info "[DRY-RUN] Les répertoires seraient créés dans : $FINAL_DEST_DIR"
fi

# Mode dry-run
if [ "$DRY_RUN" = true ]; then
    info "Simulation de la commande: rsync -av --delete $DOCS_DIR/ $FINAL_DEST_DIR/"
    exit 0
fi

# Copier les fichiers avec rsync
info "Démarrage de la copie des fichiers..."
verbose "Commande: rsync -av --delete $DOCS_DIR/ $FINAL_DEST_DIR/"

if [ "$VERBOSE" = true ]; then
    rsync -av --delete "$DOCS_DIR/" "$FINAL_DEST_DIR/" 2>> "$LOG_FILE"
else
    rsync -a --delete "$DOCS_DIR/" "$FINAL_DEST_DIR/" 2>> "$LOG_FILE"
fi

# Vérification du résultat
if [ $? -eq 0 ]; then
    success "Documents copiés avec succès dans $FINAL_DEST_DIR"
    # Ajouter des statistiques
    NB_FILES=$(find "$FINAL_DEST_DIR" -type f | wc -l)
    TOTAL_SIZE=$(du -sh "$FINAL_DEST_DIR" | cut -f1)
    info "Nombre de fichiers copiés : $NB_FILES"
    info "Taille totale : $TOTAL_SIZE"
else
    error "Échec de la copie des documents"
    exit 1
fi
