class Item < ApplicationRecord
  belongs_to :user
  belongs_to :analysis_session

  validates :jan_code, presence: true, uniqueness: { scope: :analysis_session_id }
  validates :product_name, presence: true
  validates :sales, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validate :validate_bulk_data, if: -> { @bulk_data }

  attr_accessor :bulk_data

  def validate_bulk_data
    rows = @bulk_data.split("\n")

    if rows.size < 1 || rows.size > 100
      errors.add(:bulk_data, "は最低1行、最大100行までです。")
    end

    rows.each_with_index do |row, index|
      data = row.split("\t")
      unless data.length == 3
        errors.add(:bulk_data, "の行 #{index + 1} はデータが不正です。")
      end
    end
  end

  def self.create_from_bulk(bulk_data, user, analysis_session)
    return ["Excelデータペーストエリアは空ではありませんか？"] if bulk_data.blank?
    rows = bulk_data.split("\n")

    errors = []
    rows.each_with_index do |row, index|
      data = row.split("\t")
      unless data.length == 3
        errors << "行 #{index + 1}: データが不正です。"
        next
      end

      jan_code, product_name, sales_str = data
      sales = sales_str.to_i
      item = user.items.find_or_initialize_by(jan_code: jan_code)
      item.attributes = { product_name: product_name, sales: sales, analysis_session_id: analysis_session.id }
      unless item.save
        errors << "行 #{index + 1} (JAN Code #{jan_code}): #{item.errors.full_messages.join(', ')}"
      end
    end

    errors
  end
end
