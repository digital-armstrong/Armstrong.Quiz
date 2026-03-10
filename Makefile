# Armstrong Quiz — Makefile
# Использование: make [цель]

.PHONY: help install setup server dev stop \
	db-migrate db-rollback db-seed db-reset db-setup \
	tailwind-build tailwind-watch \
	console routes test lint clean

BUNDLE := bundle
RAILS := bin/rails

# По умолчанию — справка
help:
	@echo "Armstrong Quiz — доступные цели:"
	@echo ""
	@echo "  make install      — установить гемы (bundle install)"
	@echo "  make setup        — полная установка: install + db + seed + tailwind"
	@echo "  make server       — запустить Rails сервер (port 3000)"
	@echo "  make dev          — запустить web + tailwind watch (foreman)"
	@echo "  make stop         — остановить процессы по порту 3000"
	@echo ""
	@echo "  make db-migrate   — выполнить миграции"
	@echo "  make db-rollback  — откатить последнюю миграцию"
	@echo "  make db-seed      — загрузить seeds"
	@echo "  make db-reset     — drop, create, migrate"
	@echo "  make db-setup     — db-reset + seed"
	@echo ""
	@echo "  make tailwind-build  — собрать Tailwind CSS"
	@echo "  make tailwind-watch  — watch Tailwind (для разработки)"
	@echo ""
	@echo "  make console      — Rails console"
	@echo "  make routes       — показать маршруты"
	@echo "  make test         — запустить тесты"
	@echo "  make lint         — RuboCop"
	@echo "  make clean        — удалить логи, tmp, cache"

# Установка
install:
	$(BUNDLE) install
	YARN_ENABLE_IMMUTABLE_INSTALLS=0 yarn install

setup: install db-migrate db-seed tailwind-build
	@echo "Готово. Запуск: make server или make dev"

# Сервер
server:
	$(RAILS) server

dev:
	bin/dev

stop:
	@pid=$$(lsof -ti:3000 2>/dev/null); [ -n "$$pid" ] && kill $$pid; true

# База данных
db-migrate:
	$(RAILS) db:migrate

db-rollback:
	$(RAILS) db:rollback

db-seed:
	$(RAILS) db:seed

db-reset:
	$(RAILS) db:drop db:create db:migrate

db-setup: db-reset db-seed
	@echo "База пересоздана и заполнена seeds."

# Tailwind (с daisyUI через Node)
tailwind-build:
	yarn build:css

tailwind-watch:
	yarn watch:css

# Разработка
console:
	$(RAILS) console

routes:
	$(RAILS) routes

# Тесты и линтер
test:
	$(RAILS) test

lint:
	$(BUNDLE) exec rubocop

# Очистка
clean:
	rm -rf log/* tmp/cache tmp/pids tmp/sockets
	@echo "Логи и tmp очищены."
