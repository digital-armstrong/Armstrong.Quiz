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

# Sections and categories (categories belong to a section)
quiz_structure = [
  {
    section: {
      title: "Информационные технологии",
      description: "Квизы по ИТ: администрирование, разработка, ИБ, АСУ ТП."
    },
    categories: [
      { title: "Системное администрирование", description: "Вопросы по администрированию ОС и серверов." },
      { title: "Программирование", description: "Основы программирования и алгоритмы." },
      { title: "Информационная безопасность", description: "Безопасность данных и сетей." },
      { title: "АСУ ТП", description: "Автоматизированные системы управления технологическими процессами." }
    ]
  },
  {
    section: {
      title: "Безопасность",
      description: "Требования и нормы по охране труда и специализированным видам безопасности."
    },
    categories: [
      { title: "Радиационная безопасность", description: "Работа с источниками излучения и дозиметрия." },
      { title: "Электробезопасность", description: "Правила работы с электроустановками." },
      { title: "Охрана труда", description: "Организация безопасных условий на рабочем месте." }
    ]
  }
]

quiz_structure.each do |block|
  section = Section.find_or_initialize_by(title: block[:section][:title])
  section.description = block[:section][:description]
  section.save!

  block[:categories].each do |attrs|
    cat = Category.find_or_initialize_by(title: attrs[:title])
    cat.section = section
    cat.description = attrs[:description]
    cat.save!
  end
end

puts "Seeded #{Section.count} sections, #{Category.count} categories."

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
