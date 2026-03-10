# Деплой Armstrong Quiz на echo-sonata.com

Домен: **echo-sonata.com**. Доступны два варианта деплоя: **Docker Compose + Caddy (HTTPS)** или [Kamal 2](https://kamal-deploy.org/) (Traefik).

---

## Вариант 1: Docker Compose + Caddy (HTTPS с Let's Encrypt)

Самый простой способ получить HTTPS: Caddy автоматически получает и обновляет сертификат Let's Encrypt.

### Требования

- Сервер с Docker и Docker Compose
- Домен echo-sonata.com с DNS A-записью на IP сервера
- Порты 80 и 443 свободны и открыты снаружи

### Шаги

1. **Клонируйте репозиторий на сервер** (или скопируйте файлы).

2. **Создайте `.env`** в корне проекта (см. `.env.example`):

   ```bash
   cp .env.example .env
   # Отредактируйте .env: подставьте RAILS_MASTER_KEY из config/master.key
   # Опционально: CADDY_EMAIL=ваш@email.com — для уведомлений Let's Encrypt
   ```

3. **Соберите и запустите**:

   ```bash
   docker compose build
   docker compose up -d
   ```

4. При первом запросе к **https://echo-sonata.com** Caddy запросит сертификат у Let's Encrypt. Дальше сайт будет доступен по HTTPS, куки сессии будут работать (Secure), логин сохранится.

### Полезные команды

- `docker compose logs -f caddy` — логи Caddy (в т.ч. получение сертификата)
- `docker compose logs -f app` — логи приложения
- `docker compose down` / `docker compose up -d` — остановка и запуск

### Важно

- Не задавайте `FORCE_SSL=false` при работе за Caddy: приложение получает запросы уже по HTTPS (прокси подставляет заголовки), secure-куки должны быть включены.
- Сертификаты и данные Caddy хранятся в томах `caddy_data` и `caddy_config`; при пересоздании контейнеров они сохраняются.

---

## Вариант 2: Kamal 2 (Docker + Traefik)

Проект также настроен на деплой через [Kamal 2](https://kamal-deploy.org/) (Traefik). Домен: **echo-sonata.com**.

## Требования

- VPS с публичным IP (Ubuntu 22.04 рекомендуется)
- Домен echo-sonata.com с DNS A-записью на IP сервера
- Docker Hub (или другой registry) аккаунт
- Локально: установленный Kamal (`gem install kamal` или через bundle)

## Подготовка

### 1. DNS

Укажите A-запись для `echo-sonata.com` (и при необходимости `www.echo-sonata.com`) на IP вашего сервера. SSL-сертификат Let's Encrypt будет выдан автоматически после первого деплоя.

### 2. Конфиг деплоя

В `config/deploy.yml` замените плейсхолдер на реальный IP сервера:

```yaml
servers:
  web:
    - ВАШ_IP
```

При использовании GitHub Container Registry или другого registry измените секцию `registry` (например, `server: ghcr.io`, свой username).

### 3. Секреты Kamal

Создайте директорию и файл с секретами (в репозиторий не коммитить):

```bash
mkdir -p .kamal
```

В `.kamal/secrets` (формат: `KEY=value` по одному на строку) добавьте:

- `RAILS_MASTER_KEY` — значение из `config/master.key` (или из credentials).
- Пароль/токен реестра, если Kamal просит:
  - для Docker Hub: `KAMAL_REGISTRY_PASSWORD=ваш_токен`
  - в `config/deploy.yml` в секции `registry` можно указать `password: - KAMAL_REGISTRY_PASSWORD`

Пример `.kamal/secrets`:

```
RAILS_MASTER_KEY=ваш_rails_master_key_из_config_master.key
KAMAL_REGISTRY_PASSWORD=ваш_пароль_или_токен_docker_hub
```

### 4. SSH-доступ на сервер

Убедитесь, что с вашей машины можно зайти на сервер по SSH (по ключу):

```bash
ssh root@ВАШ_IP
```

Если используете другого пользователя, укажите в `config/deploy.yml`:

```yaml
ssh:
  user: deploy
```

## Деплой

Установите гем (если ещё не установлен):

```bash
bundle install
```

Первый раз установите Kamal на сервер и задеплойте приложение:

```bash
bundle exec kamal setup
```

Дальнейшие обновления:

```bash
bundle exec kamal deploy
```

## Полезные команды Kamal

- `bundle exec kamal app logs` — логи приложения
- `bundle exec kamal app exec -i bash` — shell в контейнере
- `bundle exec kamal deploy rollback` — откат на предыдущий образ
- `bundle exec kamal traefik details` — информация о Traefik (прокси и SSL)

## Production-настройки в приложении

В `config/environments/production.rb` для echo-sonata.com уже включено:

- `config.force_ssl = true` и `config.assume_ssl = true`
- Разрешённые хосты: `echo-sonata.com`, `www.echo-sonata.com`, поддомены
- `action_mailer.default_url_options` с хостом echo-sonata.com и протоколом https

Почту (Devise, сброс пароля и т.д.) при необходимости настройте отдельно: SMTP в production или сервис (SendGrid, Mailgun и т.п.) и credentials.

## База данных

Используется SQLite в контейнере. Данные хранятся в Docker-томе `app_storage`, привязанном к `/rails/storage`. При первом деплое выполняется `db:prepare` (создание БД и миграции) через `bin/docker-entrypoint`.

## Чек-лист перед деплоем

- [ ] DNS для echo-sonata.com указывает на IP сервера
- [ ] В `config/deploy.yml` подставлен реальный IP в `servers.web`
- [ ] Создан `.kamal/secrets` с `RAILS_MASTER_KEY` и при необходимости паролем registry
- [ ] Есть `config/master.key` или значение RAILS_MASTER_KEY в секретах
- [ ] SSH-доступ на сервер по ключу работает
