class CreateLocationRegisters < ActiveRecord::Migration[6.0]
  def change
    create_table :location_registers do |t|
      t.float :latitude
      t.float :longitude
      t.integer :user_id

      t.timestamps
    end
  end
end
