class User < ApplicationRecord
  MAX_ANALYSIS_SESSIONS = 5
  # Include default devise modules without :validatable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :timeoutable, :confirmable
  scope :guests, -> { where(guest: true) }
  # Custom password validation
  VALID_PASSWORD_REGEX = /\A(?=.*?[a-z])(?=.*?[A-Z])(?=.*?[\d])\w{6,12}\z/

  validates :password, presence: true, if: :password_required?,
                       length: { in: 6..12 },
                       format: {
                         with: VALID_PASSWORD_REGEX,
                         message: "は半角6~12文字英大文字・小文字・数字それぞれ１文字以上含む必要があります",
                       }

  validates :email, presence: true, uniqueness: true
  validates :encrypted_password, presence: true
  validate :password_confirmation_matches?, if: :password_required?
  validates :name, presence: true, length: { maximum: 50 }

  has_many :analysis_sessions, dependent: :destroy
  has_many :items
  has_many :analysis_results, through: :analysis_sessions

  def timeout_in
    guest? ? 30.minutes : 1.hour
  end

  private

  def password_confirmation_matches?
    if password != password_confirmation
      errors.add(:password_confirmation, "が一致していません")
    end
  end

  def password_required?
    new_record? || password.present? || password_confirmation.present?
  end
end
