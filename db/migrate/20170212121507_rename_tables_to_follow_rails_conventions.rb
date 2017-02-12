class RenameTablesToFollowRailsConventions < ActiveRecord::Migration
  def up
    rename_table :albarans, :albaranes
    rename_table :proveedors, :proveedores
  end

  def down
    rename_table :albaranes, :albarans
    rename_table :proveedores, :proveedors
  end
end
