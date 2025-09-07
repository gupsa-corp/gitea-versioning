.PHONY: help up down restart logs backup restore clean setup

# Default target
help: ## Show this help message
	@echo "Gitea Management Commands:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

setup: ## Initial setup - copy environment file and create directories
	@echo "Setting up Gitea environment..."
	@cp .env.example .env
	@mkdir -p backups logs nginx/ssl
	@echo "Setup complete! Please edit .env file with your configuration."

up: ## Start all services
	@echo "Starting Gitea services..."
	@docker-compose up -d
	@echo "Services started. Access Gitea at http://localhost:3000"

up-with-nginx: ## Start all services including nginx reverse proxy
	@echo "Starting Gitea services with nginx..."
	@docker-compose --profile nginx up -d
	@echo "Services started with nginx reverse proxy."

down: ## Stop all services
	@echo "Stopping Gitea services..."
	@docker-compose down

restart: ## Restart all services
	@echo "Restarting Gitea services..."
	@docker-compose restart

logs: ## Show logs from all services
	@docker-compose logs -f

logs-gitea: ## Show logs from gitea service only
	@docker-compose logs -f gitea

logs-db: ## Show logs from database service only
	@docker-compose logs -f gitea-db

backup: ## Create backup of Gitea data
	@echo "Creating backup..."
	@./scripts/backup.sh

restore: ## Restore Gitea data from backup (Usage: make restore DATE=20240101_120000)
	@echo "Restoring from backup..."
	@./scripts/restore.sh $(DATE)

clean: ## Clean up all data (WARNING: This will delete all data!)
	@echo "WARNING: This will delete all Gitea data!"
	@read -p "Are you sure? [y/N] " confirm && [ "$$confirm" = "y" ]
	@docker-compose down -v
	@docker volume rm gitea-data gitea-db-data 2>/dev/null || true
	@echo "All data cleaned."

clean-images: ## Remove all Gitea related Docker images
	@docker-compose down
	@docker rmi gitea/gitea postgres nginx 2>/dev/null || true

status: ## Show status of all services
	@docker-compose ps

shell-gitea: ## Open shell in gitea container
	@docker exec -it gitea sh

shell-db: ## Open psql shell in database container
	@docker exec -it gitea-db psql -U gitea -d gitea

update: ## Update Gitea to latest version
	@echo "Updating Gitea..."
	@docker-compose pull
	@docker-compose up -d
	@echo "Update complete."

admin-user: ## Create admin user (Usage: make admin-user USER=admin EMAIL=admin@example.com PASS=password)
	@docker exec gitea gitea admin user create --username $(USER) --email $(EMAIL) --password $(PASS) --admin

monitor: ## Monitor system resources
	@docker stats gitea gitea-db