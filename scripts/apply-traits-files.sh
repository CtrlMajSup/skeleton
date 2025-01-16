#!/bin/bash

# Définition des couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Fonction pour afficher le help
show_help() {
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                 APPLY-TRAITS-FILES HELP                    ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo -e "${CYAN}Description:${NC}"
    echo -e "  Ce script crée des liens symboliques à partir des fichiers du"
    echo -e "  répertoire ./traits/ vers leur emplacement d'origine\n"
    echo -e "${CYAN}Usage:${NC}"
    echo -e "  $0 [options] [fichier_spécifique]"
    echo -e "\n${CYAN}Options:${NC}"
    echo -e "  ${GREEN}-h, --help${NC}     Affiche ce message d'aide"
    echo -e "  ${GREEN}-v, --verbose${NC}   Mode verbose (affiche plus d'informations)"
    echo -e "  ${GREEN}-d, --dry-run${NC}   Simulation (n'effectue aucune modification)"
    echo -e "\n${CYAN}Examples:${NC}"
    echo -e "  $0"
    echo -e "  $0 --verbose"
    echo -e "  $0 fichier_spécifique\n"
    echo -e "${YELLOW}Note: Ce script doit être exécuté avec les droits root${NC}\n"
}

# Fonction pour afficher les messages d'erreur
error() {
    echo -e "${RED}[ERREUR]${NC} $1" >&2
}

# Fonction pour afficher les messages d'information
info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Fonction pour afficher les messages de succès
success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Fonction pour afficher les messages en mode verbose
verbose() {
    if [ "$VERBOSE" = true ]; then
        echo -e "${PURPLE}[VERBOSE]${NC} $1"
    fi
}

# Obtenir le chemin absolu du répertoire du script
SCRIPT_PATH=$(readlink -f "$0")
SCRIPT_DIR=$(dirname "$SCRIPT_PATH")
SOURCE_DIR="${SCRIPT_DIR}/../traits"

# Initialisation des variables
VERBOSE=false
DRY_RUN=false
SPECIFIC_FILE=""

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
            if [ -z "$SPECIFIC_FILE" ]; then
                SPECIFIC_FILE="$1"
            else
                error "Arguments supplémentaires non autorisés"
                show_help
                exit 1
            fi
            shift
            ;;
    esac
done

# Vérifier les droits root
if [ "$(id -u)" -ne 0 ]; then
    error "Ce script doit être exécuté avec les droits administrateur (root)"
    show_help
    exit 1
fi

# Vérifier si le répertoire source existe
if [ ! -d "$SOURCE_DIR" ]; then
    error "Le répertoire source $SOURCE_DIR n'existe pas"
    exit 1
fi

# Fonction pour traiter un fichier
process_file() {
    local file="$1"

    # Ignorer les fichiers .sh
    if [ "${file##*.}" = "sh" ]; then
        verbose "Ignorer le fichier script: $file"
        return
    fi

    # Obtenir le nom du fichier sans le chemin
    local filename=$(basename "$file")

    # Construire le chemin du lien en remplaçant les underscores par des slashes
    local link_path=$(echo "$filename" | tr '_' '/')
    local dest_dir=$(dirname "/$link_path")

    verbose "Traitement du fichier: $file"
    verbose "Chemin du lien: /$link_path"

    if [ "$DRY_RUN" = true ]; then
        info "[DRY-RUN] Création simulée du répertoire: $dest_dir"
        info "[DRY-RUN] Création simulée du lien: $file -> /$link_path"
    else
        # Créer le répertoire de destination si nécessaire
        if [ ! -d "$dest_dir" ]; then
            verbose "Création du répertoire: $dest_dir"
            mkdir -p "$dest_dir"
            if [ $? -ne 0 ]; then
                error "Impossible de créer le répertoire $dest_dir"
                return
            fi
        fi

        # Créer le lien symbolique
        ln -sf "$(readlink -f "$file")" "/$link_path"
        if [ $? -eq 0 ]; then
            success "Lien symbolique créé: $file -> /$link_path"
        else
            error "Échec de la création du lien pour $file"
        fi
    fi
}

# Traitement principal
if [ -n "$SPECIFIC_FILE" ]; then
    specific_path="$SOURCE_DIR/$SPECIFIC_FILE"
    if [ -f "$specific_path" ]; then
        verbose "Traitement du fichier spécifique: $specific_path"
        process_file "$specific_path"
    else
        error "Le fichier spécifié n'existe pas: $specific_path"
        exit 1
    fi
else
    verbose "Traitement de tous les fichiers dans $SOURCE_DIR avec un '_' dans le nom"
    find "$SOURCE_DIR" -type f -name '*_*' | while read file; do
        process_file "$file"
    done
fi

if [ "$DRY_RUN" = true ]; then
    info "Simulation terminée - aucune modification effectuée"
else
    success "Opération terminée avec succès"
fi
