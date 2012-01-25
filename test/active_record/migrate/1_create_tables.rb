class CreateTables < ActiveRecord::Migration
  def up
    create_table :users do |t|
      t.string :sex
    end
  end
end
