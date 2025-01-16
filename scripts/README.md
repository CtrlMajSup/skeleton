# Explication de chaque script


made-traits-file.sh
Script permettant de sauvegarder les fichiers de configuration système. Il convertit les chemins absolus en noms de fichiers (remplace les '/' par des '-') et les copie dans les répertoires appropriés.

apply-traits-file.sh
Script permettant de restaurer les configurations en créant des liens symboliques vers les emplacements d'origine. Nécessite les droits root.

check-struct.sh
Script qui vérifie que les règles du template sont respectées

made-backups.sh
Script qui s'occupe de stocker les backups (à adapter à votre convenance)

restore-backups.sh
Script qui restaure les backups  (à adapter à votre convenance)

restart-service.sh
Facultatif mais utile pour la transmission de savoir. à adapter à votre convenance

push-docs.sh
Script pour centraliser les repo doc a votre convenance. Dans un git ou par rsync dans un server wiki par exmple
