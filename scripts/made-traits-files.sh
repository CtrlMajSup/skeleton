#!/bin/bash

# Définition des couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Fonction pour écrire dans les logs
log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${timestamp} [${level}] ${message}" >> "$LOG_FILE"
}

# Fonction pour afficher le help
show_help() {
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                   MADE-TRAITS-FILE HELP                    ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo -e "${CYAN}Description:${NC}"
    echo -e "  Ce script copie des fichiers en transformant leur chemin absolu"
    echo -e "  en nom de fichier (en remplaçant les '/' par des '_')\n"
    echo -e "${CYAN}Usage:${NC}"
    echo -e "  $0 [options] <source>"
    echo -e "\n${CYAN}Options:${NC}"
    echo -e "  ${GREEN}-h, --help${NC}     Affiche ce message d'aide"
    echo -e "  ${GREEN}-v, --verbose${NC}   Mode verbose (affiche plus d'informations)"
    echo -e "  ${GREEN}-d, --dry-run${NC}   Simulation (n'effectue aucune copie)"
    echo -e "\n${CYAN}Examples:${NC}"
    echo -e "  $0 /chemin/vers/fichier"
    echo -e "  $0 --verbose /chemin/vers/dossier"
    echo -e "  $0 --dry-run /chemin/vers/fichier\n"
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

# Obtenir le chemin absolu du répertoire du script, même s'il est appelé via un lien symbolique
SCRIPT_PATH=$(readlink -f "$0")
SCRIPT_DIR=$(dirname "$SCRIPT_PATH")
DEST_DIR="${SCRIPT_DIR}/../traits"
# Définition du répertoire de logs
LOGS_DIR="${SCRIPT_DIR}/../events"
LOG_FILE="${LOGS_DIR}/made-traits-file_$(date +%Y-%m-%d_%H-%M-%S).log"

# Initialisation des variables
VERBOSE=false
DRY_RUN=false
SOURCE=""

# Traitement des options
while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        *)
            if [ -z "$SOURCE" ]; then
                SOURCE="$1"
            else
                error "Arguments supplémentaires non autorisés"
                show_help
                exit 1
            fi
            shift
            ;;
    esac
done

# Vérification qu'une source a été spécifiée
if [ -z "$SOURCE" ]; then
    error "Aucune source spécifiée"
    show_help
    exit 1
fi

# Vérification et création du répertoire de destination
if [ ! -d "$DEST_DIR" ]; then
    if [ "$DRY_RUN" = false ]; then
        verbose "Création du répertoire de destination $DEST_DIR"
        mkdir -p "$DEST_DIR"
        if [ $? -ne 0 ]; then
            error "Impossible de créer le répertoire de destination"
            exit 1
        fi
    else
        info "[DRY-RUN] Le répertoire $DEST_DIR serait créé"
    fi
fi


# Vérification et création du répertoire de logs
if [ ! -d "$LOGS_DIR" ]; then
    if [ "$DRY_RUN" = false ]; then
        verbose "Création du répertoire de logs $LOGS_DIR"
        mkdir -p "$LOGS_DIR"
        if [ $? -ne 0 ]; then
            error "Impossible de créer le répertoire de logs"
            exit 1
        fi
    else
        info "[DRY-RUN] Le répertoire $LOGS_DIR serait créé"
    fi
fi

# Fonction pour traiter un fichier
process_file() {
    local file="$1"

    # Obtenir le chemin absolu du fichier
    local absolute_path=$(readlink -f "$file")

    # Créer le nouveau nom en remplaçant tous les / par des _
    local new_name=$(echo "$absolute_path" | tr '/' '_')
    local dest_path="${DEST_DIR}/${new_name}"

    verbose "Traitement du fichier : $file"
    verbose "Chemin absolu : $absolute_path"
    verbose "Nouveau nom : $new_name"

    if [ "$DRY_RUN" = true ]; then
        info "[DRY-RUN] Copie simulée: $file -> $dest_path"
    else
        cp "$file" "$dest_path"
        if [ $? -eq 0 ]; then
            success "Copié: $file -> $dest_path"
        else
            error "Échec de la copie de $file"
        fi
    fi
}

# Traitement principal
if [ -f "$SOURCE" ]; then
    verbose "Traitement d'un fichier unique"
    process_file "$SOURCE"
elif [ -d "$SOURCE" ]; then
    verbose "Traitement d'un répertoire"
    find "$SOURCE" -type f | while read file; do
        process_file "$file"
    done
else
    error "La source $SOURCE n'existe pas ou n'est ni un fichier ni un répertoire"
    exit 1
fi

if [ "$DRY_RUN" = true ]; then
    info "Simulation terminée - aucun fichier n'a été modifié"
else
    success "Opération terminée avec succès"
fi
