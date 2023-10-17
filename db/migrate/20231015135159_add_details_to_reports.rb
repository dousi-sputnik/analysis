class AddDetailsToReports < ActiveRecord::Migration[6.1]
  def change
    add_column :reports, :overview, :text
    add_column :reports, :rank_a_trend, :text
    add_column :reports, :rank_b_trend, :text
    add_column :reports, :rank_c_trend, :text
  end
end
