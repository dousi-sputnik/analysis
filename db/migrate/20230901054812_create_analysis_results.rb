class CreateAnalysisResults < ActiveRecord::Migration[6.1]
  def change
    create_table :analysis_results do |t|
      t.references :user, null: false, foreign_key: true
      t.string :jan_code
      t.string :product_name
      t.integer :sales
      t.decimal :cumulative_sales
      t.decimal :cumulative_percentage
      t.string :classification

      t.timestamps
    end
  end
end
