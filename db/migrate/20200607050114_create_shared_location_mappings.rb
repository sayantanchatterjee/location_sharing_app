class CreateSharedLocationMappings < ActiveRecord::Migration[6.0]
  def change
    create_table :shared_location_mappings do |t|
      t.integer :location_register_id
      t.integer :shared_user_id

      t.timestamps
    end
  end
end
