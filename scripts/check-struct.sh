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
LOGS_DIR="$PROJECT_ROOT/events"
LOG_FILE="$LOGS_DIR/check-template_$(date +%Y-%m-%d_%H-%M-%S).log"

# Options
VERBOSE=false

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

# Fonction pour afficher les messages de warning
warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
    log "WARNING" "$1"
}

# Fonction d'affichage du message d'aide
help() {
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                   CHECK-TEMPLATE HELP                       ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo -e "${CYAN}Description:${NC}"
    echo -e "  Ce script vérifie l'intégrité du template du projet en vérifiant les fichiers et les permissions."
    echo -e "${GREEN}Usage: ./check-template.sh${NC}"
    exit 0
}

# Vérification des permissions et types de fichiers dans le répertoire "scripts"
check_scripts() {
    info "Vérification du répertoire scripts..."
    local error_count=0
    local warning_count=0

    for file in "$PROJECT_ROOT/scripts"/*; do
        if [[ "$file" =~ README.md$ ]]; then
            continue
        fi

        if [ ! -x "$file" ]; then
            error "Le fichier $file n'est pas exécutable"
            ((error_count++))
        fi

        if [[ ! "$file" =~ \.sh$ ]]; then
            warning "Le fichier $file n'est pas un fichier .sh"
            ((warning_count++))
        fi
    done

    log "INFO" "Scripts: $error_count erreurs, $warning_count avertissements"
    return $error_count
}

# Vérification des fichiers dans "traits"
check_traits() {
    info "Vérification du répertoire traits..."
    local error_count=0

    for file in "$PROJECT_ROOT/traits"/*; do
        if [[ "$file" =~ README.md$ ]]; then
            continue
        fi

        if [[ ! "$file" =~ _ ]]; then
            error "Le fichier $file dans traits n'a pas de _ (excepté README.md)"
            ((error_count++))
        fi
    done

    log "INFO" "Traits: $error_count erreurs"
    return $error_count
}

# Vérification des fichiers dans "backups"
check_backups() {
    info "Vérification du répertoire backups..."
    local error_count=0

    for file in "$PROJECT_ROOT/backups"/*; do
        if [[ "$file" =~ README.md$ ]]; then
            continue
        fi

        if [[ ! "$file" =~ \.tar\.gz$ ]]; then
            error "Le fichier $file dans backups n'est pas un fichier .tar.gz"
            ((error_count++))
        fi
    done

    log "INFO" "Backups: $error_count erreurs"
    return $error_count
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
        * )                    help ;;
    esac
    shift
done

# Démarrage des vérifications
info "Démarrage de la vérification de l'intégrité du template"

total_errors=0
scripts_errors=0
traits_errors=0
backups_errors=0

check_scripts
scripts_errors=$?

check_traits
traits_errors=$?

check_backups
backups_errors=$?

total_errors=$((scripts_errors + traits_errors + backups_errors))

# Résumé final
if [ $total_errors -eq 0 ]; then
    success "Vérification terminée avec succès - Aucune erreur trouvée"
else
    error "Vérification terminée avec $total_errors erreur(s)"
    log "ERROR" "Résumé des erreurs: Scripts=$scripts_errors, Traits=$traits_errors, Backups=$backups_errors"
fi

exit $total_errors
