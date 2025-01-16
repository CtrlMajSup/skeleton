### 1. **Structure du Repo de Documentation**

L'objectif est de garder un répertoire organisé où chaque **instance** de service possède son propre sous-dossier de documentation. Chaque sous-dossier contient les informations liées à l'instance de service : installation, configuration, utilisation, et autres aspects pertinents.

Voici la structure proposée pour le repo `docs` :

```
/srv
└── service
    ├── doc/
    │   ├── instance1/
    │   │   ├── Install.md                # Documentation d'installation spécifique à instance1
    │   │   ├── Configure.md              # Documentation sur la configuration spécifique à instance1
    │   │   ├── Useful.md                 # Conseils pratiques pour l'utilisation de instance1
    │   │   └── Architecture.md           # Documentation sur l'architecture de instance1
    │   ├── instance2/
    │   │   ├── Install.md                # Documentation d'installation spécifique à instance2
    │   │   ├── Configure.md              # Documentation sur la configuration spécifique à instance2
    │   │   ├── Useful.md                 # Conseils pratiques pour l'utilisation de instance2
    │   │   └── Architecture.md           # Documentation sur l'architecture de instance2
    │   └── ...
    └── scripts/
        ├── docs_push.sh                  # Script rsync pour centraliser les docs
```

### 2. **Contenu des sous-dossiers de documentation**

Chaque instance de service, comme `instance1/`, `instance2/`, etc., aura des fichiers markdown (`.md`) décrivant les aspects essentiels de l'instance.

#### Exemple de structure dans `instance1/` :

- **Install.md** : Fournit des instructions détaillées sur la manière d'installer l'instance de service. Par exemple :
    ```markdown
    # Installation de l'instance1

    1. Télécharger le code source depuis le repo Git :
        ```bash
        git clone <URL-repo>
        ```
    2. Installer les dépendances :
        ```bash
        sudo apt-get install <paquet1> <paquet2>
        ```
    3. Configurer l'instance en suivant les étapes décrites dans `Configure.md`.
    ```

- **Configure.md** : Contient des instructions spécifiques à la configuration de l'instance, par exemple la configuration d'un fichier `.conf` ou `.yml`.
    ```markdown
    # Configuration de l'instance1

    - Modifier le fichier de configuration `config.yml` pour spécifier les paramètres suivants :
        ```yaml
        db_host: <hôte-de-la-base>
        db_port: <port>
        ```
    - Redémarrer le service avec `systemctl restart service`.
    ```

- **Useful.md** : Cette section contient des informations utiles, comme des astuces ou des détails pratiques pour l'exploitation de l'instance, la gestion des logs, ou des suggestions d'améliorations.
    ```markdown
    # Conseils utiles pour instance1

    - Pour surveiller les logs en temps réel, utilisez la commande :
        ```bash
        tail -f /var/log/instance1.log
        ```
    - Pour sauvegarder rapidement l'instance, utilisez le script de backup :
        ```bash
        ./scripts/backup.sh
        ```
    ```

- **Architecture.md** : Une vue d'ensemble de l'architecture de l'instance, avec des diagrammes ou des explications détaillées sur la répartition des composants.
    ```markdown
    # Architecture de instance1

    L'architecture de cette instance repose sur les composants suivants :
    - Serveur web Apache
    - Base de données MySQL
    - Serveur de cache Redis
    ```

### 3. **Centralisation des Docs via Rsync**

Le but ici est de centraliser toutes les documentations des différentes instances dans un dépôt commun ou un **agrégateur wiki**.

#### Exemple de mise en place du processus de centralisation via `rsync` :

Pour synchroniser les fichiers de documentation de chaque instance vers un dépôt centralisé (un wiki ou un répertoire commun), nous utiliserons un script `rsync`. Ce script permet de copier ou mettre à jour les documents d'une instance vers un serveur central de manière efficace.

Le script **`docs_push.sh`** dans le répertoire **`scripts/`** aura pour but de synchroniser la documentation des instances locales vers un répertoire central (par exemple, un serveur wiki ou un dépôt Git central).


#### Explication du script `docs_push.sh` :

- **Variables `DEST_DIR` et `SRC_DIR`** : Le script définit un répertoire central où la documentation sera copiée (`DEST_DIR`), et le répertoire source où se trouvent les documents de chaque instance (`SRC_DIR`).
  
- **Liste des instances** : Le tableau `INSTANCES` contient la liste des noms des instances. Vous pouvez ajouter ou modifier cette liste selon les instances de votre infrastructure.
  
- **Rsync** : Le script utilise `rsync` pour transférer la documentation de chaque instance vers le répertoire central. L'option `-av` permet de préserver les attributs des fichiers et de vérifier les différences, et l'option `--delete` permet de supprimer les fichiers dans le répertoire de destination qui ne sont plus présents dans le répertoire source.
  
- **Automatisation** : Vous pouvez exécuter ce script périodiquement (par exemple, via un cron) pour synchroniser régulièrement la documentation vers un référentiel central ou un wiki.

### 4. **Centralisation dans un Wiki Markdown**

L'idée derrière la centralisation est que les documents de chaque instance sont synchronisés dans un répertoire central, où un **Wiki en markdown** ou un autre système peut les agréger et les afficher de manière lisible.

Vous pouvez utiliser des outils comme [MkDocs](https://mkdocs.org/), [DokuWiki](https://www.dokuwiki.org/), ou tout autre système de gestion de documentation qui prend en charge le markdown. Dans ce cas, chaque instance aurait sa propre section dans le wiki, et les utilisateurs pourraient accéder à la documentation via une interface web.
