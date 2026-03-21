class User < ApplicationRecord
  ROLES = %w[student mentor admin].freeze
  STATES = %w[active archived banned].freeze

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one :profile, dependent: :destroy
  accepts_nested_attributes_for :profile

  has_many :quiz_attempts, dependent: :destroy
  has_many :evaluations_received, class_name: "Evaluation", foreign_key: :user_id, dependent: :destroy
  has_many :evaluations_given, class_name: "Evaluation", foreign_key: :admin_id, dependent: :destroy

  validates :role, inclusion: { in: ROLES }
  validates :state, inclusion: { in: STATES }
  validates :consent_to_personal_data, acceptance: { message: I18n.t("devise.consent_required") }, on: :create

  before_validation :set_default_role, on: :create
  before_validation :set_default_state, on: :create

  scope :active, -> { where(state: "active") }
  scope :students, -> { where(role: "student") }

  def admin?
    role == "admin"
  end

  def student?
    role == "student"
  end

  def mentor?
    role == "mentor"
  end

  def admin_or_mentor?
    admin? || mentor?
  end

  def active?
    state == "active"
  end

  def archived?
    state == "archived"
  end

  def banned?
    state == "banned"
  end

  def full_name
    return email unless profile

    parts = [ profile.last_name, profile.first_name ]
    parts << profile.middle_name if profile.middle_name.present?
    parts.join(" ")
  end

  def active_for_authentication?
    super && !banned?
  end

  def inactive_message
    banned? ? t("devise.failure.banned") : super
  end

  private

  def set_default_role
    self.role ||= "student"
  end

  def set_default_state
    self.state ||= "active"
  end
end
