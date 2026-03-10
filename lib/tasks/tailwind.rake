# frozen_string_literal: true

# Сборка Tailwind с daisyUI через Node (yarn build:css)
# При assets:precompile вызывается tailwindcss:build — он запускает yarn build:css
if Rake::Task.task_defined?("tailwindcss:build")
  Rake::Task["tailwindcss:build"].clear
end

namespace :tailwindcss do
  task :build do
    system("yarn build:css") || raise("Tailwind CSS build failed. Run: yarn install && yarn build:css")
  end
end
