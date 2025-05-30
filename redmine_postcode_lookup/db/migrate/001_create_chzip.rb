# File: db/migrate/001_create_chzip.rb
class CreateChzip < ActiveRecord::Migration[6.0]
  def up
    create_table :chzip, id: false do |t|
      t.string  :cty, null: false
      t.string  :reg, null: false
      t.integer :zip, null: false, primary_key: true
    end
    add_index :chzip, :zip, unique: true
  end

  def down
    drop_table :chzip
  end
end