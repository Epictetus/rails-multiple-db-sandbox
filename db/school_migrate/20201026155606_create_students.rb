class CreateStudents < ActiveRecord::Migration[6.0]
  def change
    create_table :students do |t|
      t.string :name, null: false
      t.integer :user_id, null: false
      t.references :grade, null: false, foreign_key: true
    end
  end
end
