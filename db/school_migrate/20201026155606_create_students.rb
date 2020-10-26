class CreateStudents < ActiveRecord::Migration[6.0]
  def change
    create_table :students do |t|
      t.string :name
      t.references :grade, null: false, foreign_key: true
    end
  end
end
