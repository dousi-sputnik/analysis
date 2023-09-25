class User < ApplicationRecord
  # Include default devise modules without :validatable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable
  scope :guests, -> { where(guest: true) }
  # Custom password validation
  VALID_PASSWORD_REGEX = /\A(?=.*?[a-z])(?=.*?[A-Z])(?=.*?[\d])\w{6,12}\z/
  
  validates :password, presence: true, if: :password_required?,
            length: { in: 6..12 },
            format: { with: VALID_PASSWORD_REGEX,
                      message: "は半角6~12文字英大文字・小文字・数字それぞれ１文字以上含む必要があります" }

  validates :email, presence: true, uniqueness: true
  validates :encrypted_password, presence: true
  
  has_many :analysis_sessions, dependent: :destroy
  has_many :items
  has_many :analysis_results, through: :analysis_sessions

  private

  def password_required?
    password.present? || password_confirmation.present?
  end
end
