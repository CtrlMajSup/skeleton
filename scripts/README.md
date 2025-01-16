# Explication de chaque script


made_config_file.sh
Script permettant de sauvegarder les fichiers de configuration système. Il convertit les chemins absolus en noms de fichiers (remplace les '/' par des '_') et les copie dans les répertoires appropriés.

apply_config_file.sh
Script permettant de restaurer les configurations en créant des liens symboliques vers les emplacements d'origine. Nécessite les droits root.

check_struct.sh
Script qui vérifie que les règles du template sont respectées

backup.sh
Script qui s'occupe de stocker les backups (à adapter à votre convenance)

restore.sh
Script qui restaure les backups  (à adapter à votre convenance)

update_config.sh 
Script de mise à jour des configurations, il va appliquer les softlink si ce n'est pas déjà le cas et mettre à jour les shared-traits au besoin

restart_service.sh
Facultatif mais utile pour la transmission de savoir. à adapter à votre restart_service

push_doc.sh
Script pour centraliser les repo doc a votre convenance. Dans un git ou par rsync dans un server wiki par exmple
