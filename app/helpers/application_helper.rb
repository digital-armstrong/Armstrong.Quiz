module ApplicationHelper
  # Полное ФИО для шапки; если пусто — email (например, профиль без имён).
  def nav_user_menu_label(user)
    return "" if user.blank?

    user.full_name.to_s.strip.presence || user.email
  end

  # «Фамилия И.О.» для подписей на графиках и компактного вывода.
  # Принимает User или Profile; без профиля/фамилии — +fallback+ или email пользователя.
  def fio_short(record, fallback: nil)
    return fallback.to_s if record.nil?

    last_name, first_name, middle_name = fio_components(record)

    fb = fallback
    fb = record.email if fb.nil? && record.is_a?(User)
    return fb.to_s if last_name.blank?

    initials = +""
    fn = first_name.to_s.strip
    mn = middle_name.to_s.strip
    initials << "#{fn.chars.first}." if fn.present?
    initials << "#{mn.chars.first}." if mn.present?

    ln = last_name.strip
    initials.present? ? "#{ln} #{initials}" : ln
  end

  def markdown(text)
    return "" if text.blank?

    MarkdownService.render(text).html_safe
  end

  def toast_css_class(flash_type)
    case flash_type.to_s
    when "notice", "success" then "bg-info/95 text-info-content border-info"
    when "alert", "error"   then "bg-error/95 text-error-content border-error"
    else "bg-base-100 border-base-300 shadow-lg"
    end
  end

  def fio_components(record)
    case record
    when User
      return [nil, nil, nil] unless record.profile

      p = record.profile
      [p.last_name, p.first_name, p.middle_name]
    when Profile
      [record.last_name, record.first_name, record.middle_name]
    else
      raise ArgumentError, "fio_short: expected User or Profile, got #{record.class}"
    end
  end
  private :fio_components
end
