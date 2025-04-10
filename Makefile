# Makefile pour le projet Docker Compose

# Variables
DOCKER_COMPOSE = docker compose -f srcs/docker-compose.yml
ENV_FILE = srcs/.env

# Couleurs pour une meilleure lisibilité
GREEN = \033[0;32m
YELLOW = \033[0;33m
RED = \033[0;31m
BLUE = \033[0;34m
NC = \033[0m # No Color

# Règles principales
.PHONY: all build up down restart clean fclean ps logs

# Règle par défaut: construit les images et démarre les conteneurs
all: build up

# Construit les images Docker
build:
	@echo "${BLUE}Construction des images Docker...${NC}"
	@${DOCKER_COMPOSE} build

# Démarre les conteneurs
up:
	@echo "${GREEN}Démarrage des conteneurs...${NC}"
	@${DOCKER_COMPOSE} up -d
	@echo "${GREEN}Conteneurs démarrés avec succès !${NC}"
	@echo "${YELLOW}Attendez quelques instants que tous les services soient prêts...${NC}"
	@sleep 5
	@echo "${GREEN}Pour voir les logs en temps réel, exécutez: make logs${NC}"
	@${DOCKER_COMPOSE} ps

# Arrête les conteneurs
down:
	@echo "${YELLOW}Arrêt des conteneurs...${NC}"
	@${DOCKER_COMPOSE} down
	@echo "${GREEN}Conteneurs arrêtés avec succès !${NC}"

# Redémarre les conteneurs
restart: down up

# Arrête et supprime les conteneurs
clean:
	@echo "${YELLOW}Nettoyage des conteneurs...${NC}"
	@${DOCKER_COMPOSE} down -v --remove-orphans
	@echo "${GREEN}Conteneurs nettoyés avec succès !${NC}"

# Supprime complètement tous les conteneurs, images et volumes
fclean: clean
	@echo "${RED}Suppression complète des conteneurs, images et volumes...${NC}"
	@docker system prune -af
	@echo "${GREEN}Suppression complète terminée !${NC}"

# Affiche l'état des conteneurs
ps:
	@echo "${BLUE}État des conteneurs:${NC}"
	@${DOCKER_COMPOSE} ps

# Affiche les logs
logs:
	@echo "${BLUE}Affichage des logs (ctrl+c pour quitter)...${NC}"
	@${DOCKER_COMPOSE} logs -f

# Affiche les logs d'un service spécifique
log-%:
	@echo "${BLUE}Affichage des logs pour $* (ctrl+c pour quitter)...${NC}"
	@${DOCKER_COMPOSE} logs -f $*

# Affiche les variables d'environnement
env:
	@echo "${BLUE}Variables d'environnement:${NC}"
	@cat ${ENV_FILE}

# Exécute un shell dans un conteneur spécifique
shell-%:
	@echo "${BLUE}Ouverture d'un shell dans le conteneur $*...${NC}"
	@${DOCKER_COMPOSE} exec $* /bin/bash || ${DOCKER_COMPOSE} exec $* /bin/sh

# Redémarre un service spécifique
restart-%:
	@echo "${YELLOW}Redémarrage du service $*...${NC}"
	@${DOCKER_COMPOSE} restart $*
	@echo "${GREEN}Service $* redémarré !${NC}"

# Construit une image spécifique
build-%:
	@echo "${BLUE}Construction de l'image $*...${NC}"
	@${DOCKER_COMPOSE} build $*
	@echo "${GREEN}Image $* construite !${NC}"

# Backup des données WordPress et MariaDB
backup:
	@echo "${BLUE}Création d'une sauvegarde...${NC}"
	@mkdir -p ./backups/$(shell date +%Y%m%d_%H%M%S)
	@docker run --rm --volumes-from $$(${DOCKER_COMPOSE} ps -q wordpress) -v $$(pwd)/backups/$(shell date +%Y%m%d_%H%M%S):/backup alpine tar -czf /backup/wordpress_files.tar.gz /var/www/html
	@${DOCKER_COMPOSE} exec -T mariadb mysqldump -u root -p$$(cat secrets/db_root_password.txt) --all-databases > ./backups/$(shell date +%Y%m%d_%H%M%S)/database_dump.sql
	@echo "${GREEN}Sauvegarde créée dans ./backups/$(shell date +%Y%m%d_%H%M%S) !${NC}"

# Affiche l'aide
help:
	@echo "${BLUE}=== COMMANDES DISPONIBLES ===${NC}"
	@echo "${GREEN}make all${NC}        - Construit les images et démarre les conteneurs"
	@echo "${GREEN}make build${NC}      - Construit toutes les images Docker"
	@echo "${GREEN}make build-X${NC}    - Construit l'image du service X (ex: make build-wordpress)"
	@echo "${GREEN}make up${NC}         - Démarre tous les conteneurs"
	@echo "${GREEN}make down${NC}       - Arrête tous les conteneurs"
	@echo "${GREEN}make restart${NC}    - Redémarre tous les conteneurs"
	@echo "${GREEN}make restart-X${NC}  - Redémarre le service X (ex: make restart-nginx)"
	@echo "${GREEN}make clean${NC}      - Arrête et supprime les conteneurs"
	@echo "${GREEN}make fclean${NC}     - Supprime complètement les conteneurs, images et volumes"
	@echo "${GREEN}make ps${NC}         - Affiche l'état des conteneurs"
	@echo "${GREEN}make logs${NC}       - Affiche les logs de tous les conteneurs"
	@echo "${GREEN}make log-X${NC}      - Affiche les logs du service X (ex: make log-wordpress)"
	@echo "${GREEN}make shell-X${NC}    - Ouvre un shell dans le conteneur X (ex: make shell-mariadb)"
	@echo "${GREEN}make env${NC}        - Affiche les variables d'environnement"
	@echo "${GREEN}make backup${NC}     - Crée une sauvegarde des données WordPress et MariaDB"