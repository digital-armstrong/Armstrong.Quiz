# Armstrong Quiz

Квиз-опросник для студентов. Студенты проходят квиз по вопросам; администраторы управляют категориями, вопросами, вариантами ответов и оценивают студентов.

## Стек

- Ruby on Rails 8.1
- Hotwire (Turbo + Stimulus)
- Importmap (JS)
- Tailwind CSS
- Devise (аутентификация)
- Pundit (авторизация)
- Commonmarker (Markdown)
- Chartkick (графики в админке)
- daisyUI v5 (компоненты UI)

## Требования

- Ruby 3.4+
- SQLite3
- Yarn (для сборки Tailwind + daisyUI)

## Установка и запуск

```bash
# Гемы
bundle install

# Node-зависимости (Tailwind CSS + daisyUI)
yarn install

# Миграции и сиды
bin/rails db:migrate
bin/rails db:seed

# Сборка CSS (один раз или при изменении стилей)
yarn build:css
# или: make tailwind-build

# Запуск (web + watch CSS через Procfile)
bin/dev
# или только сервер:
bin/rails server
```

Откройте http://localhost:3000

## Учётные данные после seed

- **Админ:** admin@example.com / password123  
- Регистрация студентов — с обязательным согласием на обработку персональных данных (152-ФЗ). Текст соглашения: `/privacy`.

## Роли

- **student** — прохождение квиза, комментарии к ответам
- **admin** — категории, вопросы, варианты ответов, результаты, оценивание студентов

## Маршруты

| Путь | Назначение |
|------|------------|
| `/` | Главная / старт квиза |
| `/quiz` | Текущий вопрос квиза (GET) или создание попытки (POST) |
| `/privacy` | Соглашение о персональных данных (Markdown) |
| `/admin` | Админ-панель (категории, вопросы, результаты, оценки) |

## Markdown

- Вопросы и варианты ответов поддерживают Markdown.
- Хелпер `markdown(text)` и сервис `MarkdownService.render(text)`.
- Контент выводится в контейнере с классом `.markdown` (стили в `app/assets/tailwind/application.css`).

## daisyUI

Подключён daisyUI v5 через `@plugin "daisyui"` в `app/assets/tailwind/application.css`. Сборка Tailwind выполняется через Node (`yarn build:css` / `yarn watch:css`), чтобы плагин корректно подхватывался. Тема по умолчанию: `data-theme="light"` в layout.
