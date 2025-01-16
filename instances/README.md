# Répertoire `instance`

## Description

Le répertoire **`instance/`** contient le **code source** et les **fichiers spécifiques** de chaque instance de service, que ce soit sous forme d'un **repository Git**, d'une **application Docker**, ou d'autres formes d'instances. Il représente le cœur du service, dans lequel sont stockées toutes les ressources nécessaires à l'exécution du service dans son environnement.

Chaque instance peut être configurée, déployée et exécutée indépendamment des autres, mais toutes suivent une structure similaire afin de simplifier la gestion des services.

## Structure du Répertoire

```
/srv
└── service
    ├── instances/
    │   ├── native/                        # Code source de l'application ou repo Git cloné
    │   ├── docker/                        # Dossier contenant les configurations Docker                      
    └── README.md                          # Documentation de l'instance
```


### Lancer l'application
Une fois l'instance configurée (qu'elle soit Docker, un Git clone, ou autre), vous pouvez démarrer le service selon la méthode appropriée pour l'instance.

## Gestion des Instances

Les instances sont des entités indépendantes qui peuvent être déployées et mises à jour de manière autonome. Il est recommandé de suivre les étapes suivantes lors de la gestion des instances :

### Mise à jour de l'instance

1. **Mettre à jour le code source** : Si l'instance est un dépôt Git, vous pouvez simplement faire un `git pull` dans son dossier ou bien dans un autre dossier mais il faudra alors préciser la version
2. **Redéployer avec Docker** : Si vous utilisez Docker, vous pouvez reconstruire et redéployer l'instance avec la commande `docker-compose up --build`.
3. **Redémarrer l'application** : Redémarrez l'application si nécessaire pour appliquer les modifications, par exemple via Docker ou tout autre mécanisme que vous utilisez.

### Sauvegarde et Restauration des Données

Il est crucial de configurer des mécanismes de sauvegarde pour les données de l'instance (dans le dossier `data/`). Vous pouvez utiliser des scripts ou des outils comme `rsync` pour créer des sauvegardes régulières.

## Conclusion

Le répertoire **`instance/`** est la base de chaque service. Il contient tout le nécessaire pour déployer, configurer et gérer une instance de service, qu'il s'agisse d'une application Docker, d'un repository Git cloné ou d'une autre forme d'instance.

Ce répertoire permet d'isoler chaque instance, rendant le déploiement, la mise à jour et la gestion des services plus modulaires et organisées.
