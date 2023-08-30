class Item < ApplicationRecord
  belongs_to :user
  validates :jan_code, presence: true, uniquness: true
  validates :product_name, presence: true
  validates :sales, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0}
end
