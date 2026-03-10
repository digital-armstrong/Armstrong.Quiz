# frozen_string_literal: true

# Сборка Tailwind с daisyUI через Node (yarn build:css).
# При assets:precompile вызывается tailwindcss:build. В Docker CSS собирают в отдельном stage
# и ставят TAILWIND_SKIP_BUILD=1 — тогда здесь ничего не запускаем.
if Rake::Task.task_defined?("tailwindcss:build")
  Rake::Task["tailwindcss:build"].clear
end

namespace :tailwindcss do
  task :build do
    if ENV["TAILWIND_SKIP_BUILD"] == "1"
      next
    end
    out = Rails.root.join("app/assets/builds/tailwind.css")
    if out.exist?
      next
    end
    # В Docker в build-stage нет Node/yarn — не запускаем сборку (CSS уже скопирован из stage tailwind)
    unless system("which yarn >/dev/null 2>&1")
      next
    end
    system("yarn build:css") || raise("Tailwind CSS build failed. Run: yarn install && yarn build:css")
  end
end
