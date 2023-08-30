class CreateItems < ActiveRecord::Migration[6.1]
  def change
    create_table :items do |t|
      t.references :user, null: false, foreign_key: true
      t.string :jan_code, null: false
      t.string :product_name, null: false
      t.integer :sales, null: false

      t.timestamps
    end
    add_index :items, :jan_code, unique: true
  end
end
