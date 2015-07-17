class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :pro
      t.text :content

      t.timestamps null: false
    end
  end
end
