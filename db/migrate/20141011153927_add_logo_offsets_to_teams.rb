class AddLogoOffsetsToTeams < ActiveRecord::Migration
  def change
    add_column :teams, :logo_offset_x, :integer
    add_column :teams, :logo_offset_y, :integer
  end
end
