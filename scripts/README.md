# Explication de chaque script


made_config_file.sh
Script permettant de sauvegarder les fichiers de configuration système. Il convertit les chemins absolus en noms de fichiers (remplace les '/' par des '_') et les copie dans les répertoires appropriés.

apply_config_file.sh
Script permettant de restaurer les configurations en créant des liens symboliques vers les emplacements d'origine. Nécessite les droits root.
