class CreateReports < ActiveRecord::Migration[6.1]
  def change
    create_table :reports do |t|
      t.text :content
      t.references :analysis_session, null: false, foreign_key: true

      t.timestamps
    end
  end
end
