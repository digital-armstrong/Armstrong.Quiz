# frozen_string_literal: true

# Create admin user if missing
admin = User.find_or_initialize_by(email: "admin@example.com")
if admin.new_record?
  admin.password = "password123"
  admin.password_confirmation = "password123"
  admin.role = "admin"
  admin.consent_to_personal_data = true
  admin.save!
  puts "Created admin: admin@example.com / password123"
end

# Example categories
categories_data = [
  { title: "Системное администрирование", description: "Вопросы по администрированию ОС и серверов." },
  { title: "Программирование", description: "Основы программирования и алгоритмы." },
  { title: "Информационная безопасность", description: "Безопасность данных и сетей." },
  { title: "АСУ ТП", description: "Автоматизированные системы управления технологическими процессами." }
]

categories_data.each do |attrs|
  Category.find_or_create_by!(title: attrs[:title]) do |c|
    c.description = attrs[:description]
  end
end

puts "Seeded #{Category.count} categories."

# Optional: one sample question with options
cat = Category.find_by(title: "Программирование")
if cat && Question.where(category: cat).empty?
  q = cat.questions.create!(
    title: "Что такое переменная?",
    body: "Выберите наиболее точное определение."
  )
  q.answer_options.create!([{ body: "Именованная область памяти для хранения значения", correct: true, position: 1 }, { body: "Функция для вывода текста", correct: false, position: 2 }])
  puts "Created sample question in Программирование."
end
