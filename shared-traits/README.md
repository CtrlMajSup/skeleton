# Répertoire `shared-traits`

## Description

Le répertoire **`shared-traits/`** contient des fichiers de configuration **préparatoires** pour les services communs. Ces fichiers de configuration sont utilisés pour compléter les vrais fichiers de configuration dans les répertoires système (par exemple,cron, supervisor, etc.). Ces fichiers sont créés de manière standardisée, selon une nomenclature définie et sont gérés par le script `scripts/fill_file.sh`.

Les fichiers dans ce répertoire **sont donc pas utilisés directement par le système**, car ils servent de modèles et de points de référence pour les fichiers de configuration réels qui seront alors des remplacer par des lien symboliques.

## Structure du Répertoire

```
/srv
└── service
    ├── traits/
    │   ├── _etc_apache2_site-available_map.conf     # Exemple de fichier de configuration Apache
    │   ├── _etc_nginx_site-available_prod.conf      # Exemple de fichier de configuration Nginx
    │   ├── _etc_mysql_my.cnf                       # Exemple de fichier de configuration MySQL
    │   └── _etc_postgresql_pg_hba.conf             # Exemple de fichier de configuration PostgreSQL
    └── README.md                                    # Documentation sur l'utilisation du répertoire traits
```

### 1. **Nommage des fichiers de configuration**
Les fichiers de configuration dans le répertoire `shared-traits/` suivent une **nomenclature précise** et doivent respecter le format suivant :

- **Format:** `_` à la place de `_` pour indiquer le chemin du fichier de configuration destiné à être lié (comme `/etc/apache2`, `/etc/nginx`).
- **Nom spécifique :** Le nom doit correspondre à la configuration exacte dans le répertoire cible (par exemple, `site-available_map.conf` pour Apache).
