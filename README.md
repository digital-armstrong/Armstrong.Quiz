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

## Роли и права (Pundit)

Авторизация описана в `app/policies/*.rb`. Дополнительно в админке контроллеры с `require_full_admin!` доступны **только администратору**; остальные экраны под `/admin` открыты и админу, и наставнику (`require_admin_or_mentor!` в `Admin::BaseController`).

### Студент (`student`)

- **Квиз:** `QuizAttemptPolicy#create?` — только студент может начать новую попытку; `show?` / `update?` — своя попытка (`record.user_id == user.id`) или админ при просмотре чужих данных в админке.
- **Ответы:** `UserAnswerPolicy#create?` — только студент и только в рамках своей активной попытки. Практически ответы создаются из `QuizController`, где дополнительно стоит `require_student!`.
- **Область видимости ответов (`UserAnswerPolicy::Scope`):** студент видит только ответы, привязанные к своим попыткам.
- **Админ-панель:** нет доступа к `Admin::*` (редирект с корня при отсутствии прав).

### Администратор (`admin`)

- **Контент квиза (только админ + `require_full_admin!`):** разделы, категории, вопросы, варианты ответов, пользователи — политики `SectionPolicy`, `CategoryPolicy`, `QuestionPolicy`, `AnswerOptionPolicy`, `UserPolicy` (все действия CRUD, бан/архив/активация пользователей).
- **Попытки:** `QuizAttemptPolicy` — `index?` и просмотр любой попытки (`show?` для админа).
- **Проверка ответов:** `UserAnswerPolicy#update?` — выставление `admin_correct` для ответов без выбранного варианта (текстовые ответы).
- **Оценки:** `EvaluationPolicy` — создание и редактирование оценок студентов; `destroy?` в политике только у админа (при появлении соответствующего действия в UI).

### Наставник (`mentor`)

- **Те же разделы админки, что и у админа, но без «полного» админа:** вход в `/admin` разрешён (`admin_or_mentor?`), но экраны с `require_full_admin!` (разделы, категории, вопросы, варианты, пользователи) недоступны — редирект с предупреждением.
- **Результаты и оценки:** просмотр результатов студентов, сводка оценок, создание и правка **своих** оценок (`EvaluationPolicy` для `index?` / `show?` / `create?` / `update?`).
- **Проверка ответов:** как у админа — `UserAnswerPolicy#update?` (`admin_or_mentor?`).
- **Управление пользователями и контентом квиза:** политики `UserPolicy`, `SectionPolicy`, `CategoryPolicy`, `QuestionPolicy`, `AnswerOptionPolicy` для ментора дают отказ — доступ режется на уровне контроллера до вызова `authorize`.

### Гость

Не аутентифицирован — публичные страницы (главная, регистрация, вход, политика конфиденциальности); политики Pundit для гостя в основном дают `scope.none` / запрет действий там, где вызывается `authorize`.

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
