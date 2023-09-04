class Item < ApplicationRecord
  belongs_to :user
  belongs_to :analysis_session

  validates :jan_code, presence: true, uniqueness: { scope: :user_id }
  validates :product_name, presence: true
  validates :sales, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
