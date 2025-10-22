.PHONY: help dev build test test-backend test-frontend test-e2e lint format type-check clean migrate migrate-create db-seed db-backup install setup

# Color output
RED=\033[0;31m
GREEN=\033[0;32m
YELLOW=\033[1;33m
NC=\033[0m # No Color

help: ## Show this help message
	@echo "$(GREEN)Kharisma Abadi V2 - Available Commands$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "$(YELLOW)%-20s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(GREEN)Examples:$(NC)"
	@echo "  make dev          Start development environment"
	@echo "  make test         Run all tests"
	@echo "  make lint         Check code style"
	@echo ""

# ============================================
# DEVELOPMENT & BUILDING
# ============================================

dev: ## Start complete development environment
	@echo "$(GREEN)Starting development environment...$(NC)"
	docker-compose -f docker-compose.yml -f docker-compose.dev.yml up

dev-detached: ## Start development environment in background
	@echo "$(GREEN)Starting development environment (detached)...$(NC)"
	docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d

dev-logs: ## Show logs from running containers
	docker-compose logs -f

dev-stop: ## Stop development environment
	@echo "$(YELLOW)Stopping development environment...$(NC)"
	docker-compose stop

dev-down: ## Stop and remove development containers
	@echo "$(RED)Removing development containers...$(NC)"
	docker-compose down

build: ## Build all services (Docker images)
	@echo "$(GREEN)Building all services...$(NC)"
	docker-compose build

build-backend: ## Build backend Docker image
	@echo "$(GREEN)Building backend...$(NC)"
	docker-compose build backend

build-frontend: ## Build frontend Docker image
	@echo "$(GREEN)Building frontend...$(NC)"
	docker-compose build frontend

# ============================================
# TESTING
# ============================================

test: test-backend test-frontend ## Run all tests
	@echo "$(GREEN)✓ All tests passed!$(NC)"

test-backend: ## Run backend unit tests
	@echo "$(GREEN)Running backend tests...$(NC)"
	cd backend && go test -v -race -coverprofile=coverage.out ./...
	@echo "$(GREEN)✓ Backend tests passed$(NC)"

test-backend-coverage: ## Run backend tests with coverage report
	@echo "$(GREEN)Running backend tests with coverage...$(NC)"
	cd backend && go test -v -race -coverprofile=coverage.out ./...
	go tool cover -html=backend/coverage.out -o coverage.html
	@echo "$(GREEN)Coverage report: coverage.html$(NC)"

test-frontend: ## Run frontend unit tests
	@echo "$(GREEN)Running frontend tests...$(NC)"
	cd frontend && npm test -- --coverage --watchAll=false
	@echo "$(GREEN)✓ Frontend tests passed$(NC)"

test-e2e: ## Run E2E tests (Playwright)
	@echo "$(GREEN)Running E2E tests...$(NC)"
	cd frontend && npm run test:e2e
	@echo "$(GREEN)✓ E2E tests passed$(NC)"

test-watch: ## Run frontend tests in watch mode
	@echo "$(GREEN)Running tests in watch mode...$(NC)"
	cd frontend && npm test

# ============================================
# CODE QUALITY
# ============================================

lint: lint-backend lint-frontend ## Run all linters
	@echo "$(GREEN)✓ All linting passed!$(NC)"

lint-backend: ## Lint backend code
	@echo "$(GREEN)Linting backend...$(NC)"
	cd backend && golangci-lint run
	@echo "$(GREEN)✓ Backend linting passed$(NC)"

lint-frontend: ## Lint frontend code
	@echo "$(GREEN)Linting frontend...$(NC)"
	cd frontend && npm run lint
	@echo "$(GREEN)✓ Frontend linting passed$(NC)"

format: format-backend format-frontend ## Format all code
	@echo "$(GREEN)✓ Code formatting complete!$(NC)"

format-backend: ## Format backend code
	@echo "$(GREEN)Formatting backend...$(NC)"
	cd backend && go fmt ./...
	cd backend && goimports -w .
	@echo "$(GREEN)✓ Backend formatting complete$(NC)"

format-frontend: ## Format frontend code
	@echo "$(GREEN)Formatting frontend...$(NC)"
	cd frontend && npm run format
	@echo "$(GREEN)✓ Frontend formatting complete$(NC)"

type-check: type-check-backend type-check-frontend ## Run all type checkers

type-check-backend: ## Type check backend (Go vet)
	@echo "$(GREEN)Type checking backend...$(NC)"
	cd backend && go vet ./...
	@echo "$(GREEN)✓ Backend type check passed$(NC)"

type-check-frontend: ## Type check frontend (TypeScript)
	@echo "$(GREEN)Type checking frontend...$(NC)"
	cd frontend && npx tsc --noEmit
	@echo "$(GREEN)✓ Frontend type check passed$(NC)"

# ============================================
# DATABASE
# ============================================

migrate: ## Run pending database migrations
	@echo "$(GREEN)Running database migrations...$(NC)"
	cd backend && go run migrations/main.go

migrate-create: ## Create new migration (prompts for message)
	@read -p "Enter migration description: " desc; \
	echo "$(GREEN)Creating migration: $$desc$(NC)"; \
	cd backend && go run cmd/migrate/main.go -create "$$desc"

migrate-rollback: ## Rollback last migration
	@echo "$(YELLOW)Rolling back last migration...$(NC)"
	cd backend && go run migrations/main.go --rollback

db-seed: ## Seed database with sample data
	@echo "$(GREEN)Seeding database with sample data...$(NC)"
	cd backend && go run cmd/seed/main.go
	@echo "$(GREEN)✓ Database seeded$(NC)"

db-backup: ## Create database backup
	@echo "$(GREEN)Creating database backup...$(NC)"
	./scripts/backup-db.sh
	@echo "$(GREEN)✓ Backup complete$(NC)"

db-reset: ## Reset database (WARNING: Deletes all data)
	@echo "$(RED)⚠️  WARNING: This will delete all database data!$(NC)"
	@read -p "Type 'yes' to confirm: " confirm; \
	if [ "$$confirm" = "yes" ]; then \
		echo "$(RED)Resetting database...$(NC)"; \
		docker-compose down -v; \
		docker-compose up -d database; \
		sleep 5; \
		make migrate; \
		echo "$(GREEN)✓ Database reset complete$(NC)"; \
	else \
		echo "$(YELLOW)Cancelled$(NC)"; \
	fi

# ============================================
# DEPENDENCIES
# ============================================

install: ## Install all dependencies
	@echo "$(GREEN)Installing dependencies...$(NC)"
	@echo "$(GREEN)Installing backend dependencies...$(NC)"
	cd backend && go mod download && go mod tidy
	@echo "$(GREEN)Installing frontend dependencies...$(NC)"
	cd frontend && npm ci
	@echo "$(GREEN)✓ Dependencies installed$(NC)"

setup: ## Initial project setup (copy .env files)
	@echo "$(GREEN)Setting up project...$(NC)"
	@if [ ! -f backend/.env ]; then \
		echo "$(YELLOW)Copying backend .env.example to .env$(NC)"; \
		cp backend/.env.example backend/.env; \
	fi
	@if [ ! -f frontend/.env.local ]; then \
		echo "$(YELLOW)Copying frontend .env.local.example to .env.local$(NC)"; \
		cp frontend/.env.local.example frontend/.env.local; \
	fi
	@echo "$(GREEN)✓ Setup complete!$(NC)"
	@echo "$(YELLOW)Next steps:$(NC)"
	@echo "1. Edit backend/.env with your database credentials"
	@echo "2. Edit frontend/.env.local with API configuration"
	@echo "3. Run: make dev"

# ============================================
# UTILITIES & CLEANUP
# ============================================

clean: ## Clean build artifacts and cache
	@echo "$(RED)Cleaning build artifacts...$(NC)"
	@find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	@find . -type f -name "*.pyc" -delete 2>/dev/null || true
	@find . -type d -name "node_modules" -exec rm -rf {} + 2>/dev/null || true
	@find . -type d -name ".next" -exec rm -rf {} + 2>/dev/null || true
	@find . -type d -name "dist" -exec rm -rf {} + 2>/dev/null || true
	@find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
	@find . -type d -name ".mypy_cache" -exec rm -rf {} + 2>/dev/null || true
	@find . -type d -name "coverage" -exec rm -rf {} + 2>/dev/null || true
	@rm -f backend/coverage.out coverage.html
	@echo "$(GREEN)✓ Cleanup complete$(NC)"

docker-clean: ## Remove all Docker images and containers
	@echo "$(RED)⚠️  WARNING: This will remove all Docker resources!$(NC)"
	@read -p "Type 'yes' to confirm: " confirm; \
	if [ "$$confirm" = "yes" ]; then \
		docker-compose down -v; \
		docker system prune -a -f; \
		echo "$(GREEN)✓ Docker cleanup complete$(NC)"; \
	else \
		echo "$(YELLOW)Cancelled$(NC)"; \
	fi

logs: ## Show logs from all containers
	docker-compose logs -f

logs-backend: ## Show logs from backend container
	docker-compose logs -f backend

logs-frontend: ## Show logs from frontend container
	docker-compose logs -f frontend

logs-database: ## Show logs from database container
	docker-compose logs -f database

shell-backend: ## Open shell in backend container
	docker-compose exec backend /bin/sh

shell-frontend: ## Open shell in frontend container
	docker-compose exec frontend /bin/sh

shell-database: ## Open MySQL shell in database container
	docker-compose exec database mysql -u root -p$$MYSQL_ROOT_PASSWORD

# ============================================
# DOCUMENTATION
# ============================================

docs: ## Open documentation in browser (if available)
	@echo "$(GREEN)Documentation available at:$(NC)"
	@echo "- Main: file://$(PWD)/REFERENCE.md"
	@echo "- API: http://localhost:8000/docs"
	@echo "- Architecture: file://$(PWD)/docs/architecture/README.md"

# ============================================
# GIT & VERSION CONTROL
# ============================================

git-status: ## Show git status
	git status

git-log: ## Show recent commits
	git log --oneline -10

# ============================================
# CI/CD SIMULATION (Local Testing)
# ============================================

ci: lint test ## Run local CI checks (lint + test)
	@echo "$(GREEN)✓ All CI checks passed!$(NC)"

# ============================================
# DEFAULT
# ============================================

.DEFAULT_GOAL := help

# Print help on unknown target
.PHONY: %
%:
	@echo "Unknown target: $@"
	@echo "Run 'make help' for available commands"
	@exit 1
