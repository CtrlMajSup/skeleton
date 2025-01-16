# Répertoire `event` (Logs des Scripts)

## Description

Le répertoire **`event`** contient les logs associés aux **scripts** dans le repo **`scripts`**. Ce répertoire ne contient pas les logs des instances de service, mais les logs des opérations effectuées par les scripts (par exemple, le déploiement, les backups, la gestion de la configuration, etc.).

Les logs sont générés par différents scripts de gestion du service et sont cruciaux pour le suivi des opérations, la gestion des erreurs, et l’analyse des performances des tâches automatisées.

## Structure du Répertoire

```
/srv
└── service
    ├── event/
    │   ├── deploy/
    │   │   ├── deploy.log                # Logs du script de déploiement
    │   ├── backup/
    │   │   ├── backup.log                # Logs du script de sauvegarde
    │   ├── config_update/
    │   │   ├── config_update.log         # Logs du script de mise à jour de la configuration
    │   ├── error.log                     # Logs généraux des erreurs des scripts
    │   └── README.md                     # Documentation de gestion des logs
```

## Description des Sous-Dossiers

Le répertoire **`event/`** est organisé en sous-dossiers, chacun correspondant à un type d'événement ou de script spécifique. Chaque dossier contient des logs détaillant les actions et résultats des scripts associés.

### 1. **`deploy/`**
Ce dossier contient les logs générés par les scripts de **déploiement** de services. Ces logs suivent les étapes de déploiement, les succès ou les échecs des différentes étapes, et incluent des informations de diagnostics.

- **`deploy.log`** : Contient les logs détaillés du script de déploiement, incluant les étapes d'installation, de mise à jour, et de redémarrage des services.

### 2. **`backup/`**
Ce dossier contient les logs générés par les scripts de **sauvegarde** des services et des données associées.

- **`backup.log`** : Contient les logs détaillés du processus de sauvegarde, y compris la création des archives, la validation des fichiers sauvegardés, et les erreurs éventuelles.

### 3. **`config_update/`**
Ce dossier contient les logs des scripts qui mettent à jour les **fichiers de configuration** des services.

- **`config_update.log`** : Enregistre les actions de mise à jour des configurations, telles que la modification des fichiers de configuration, l'application des changements et les résultats des tests.

### 4. **`error.log`**
Ce fichier contient les erreurs générales rencontrées lors de l'exécution de tous les scripts. Il inclut des erreurs critiques, comme des problèmes de permissions ou des erreurs liées aux dépendances manquantes, ainsi que des exceptions non gérées par les scripts.

- **`error.log`** : Un fichier centralisé pour les erreurs, permettant une gestion plus facile des incidents qui peuvent affecter plusieurs scripts.

## Utilisation des Logs

Les logs contenus dans ce répertoire sont essentiels pour le suivi des actions effectuées par les scripts et permettent de comprendre en détail le comportement des processus automatisés. Ces logs sont utilisés principalement pour :

- Diagnostiquer les erreurs ou problèmes pendant l'exécution des scripts.
- Analyser les performances des scripts (temps d'exécution, réussite ou échec des tâches).
- Traquer les modifications apportées par les scripts, comme les mises à jour de configuration ou les déploiements.

### Accéder aux Logs

Les logs peuvent être consultés directement depuis leur emplacement dans le répertoire `event/`. Utilisez un éditeur de texte ou des outils de commande comme `cat`, `less`, ou `tail` pour examiner le contenu des fichiers log.

Exemples de commandes pour lire les logs :

- Pour afficher les dernières lignes de `deploy.log` :
  ```bash
  tail -n 50 /srv/service/event/deploy/deploy.log
  ```
- Pour afficher le contenu complet de `error.log` :
  ```bash
  cat /srv/service/event/error.log
  ```

### Gestion des Logs

Les logs peuvent être purgés ou archivés périodiquement pour éviter qu'ils ne consomment trop d'espace disque. Une procédure typique pour gérer les logs est la suivante :

1. **Archivage des logs** : Sauvegarder les logs dans un autre répertoire (par exemple `/srv/service/backups/logs_archives/`) avant de les supprimer.
2. **Rotation des logs** : Utiliser un outil comme `logrotate` pour gérer automatiquement la rotation des logs afin de limiter leur taille et leur durée de rétention.

### Exemple de rotation des logs avec `logrotate`

Voici un exemple de configuration pour **`logrotate`** pour gérer la rotation des logs dans le dossier `event` :

```bash
/srv/service/event/*.log {
    daily
    rotate 7
    compress
    missingok
    notifempty
    create 640 root root
}
```

Cela permet de conserver les logs des sept derniers jours, de les compresser et de les supprimer après cette période.

## Conclusion

Le répertoire **`event/`** permet de centraliser tous les logs générés par les scripts de gestion des services. Ces logs sont essentiels pour assurer la traçabilité, le diagnostic, et la gestion des incidents liés aux processus automatisés. 

Assurez-vous de mettre en place une stratégie de gestion et de rotation des logs pour garantir une utilisation optimale de l'espace disque tout en maintenant la disponibilité des informations critiques.
