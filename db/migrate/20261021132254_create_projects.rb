class CreateProjects < ActiveRecord::Migration[8.1]
  def change
    create_table :projects do |t|
      t.references :user, null: false, foreign_key: true, index: false
      t.string :name, null: false, limit: 100
      t.timestamps

      t.index %i[user_id name], unique: true
    end
  end
end
