class CreateTables < ActiveRecord::Migration
  def up
    create_table :users do |t|
      t.string :sex
      t.string :role
    end
  end
end
