class CreateLineHistories < ActiveRecord::Migration[5.1]
  def change
    create_table :line_histories do |t|
      t.integer :month
      t.integer :traffic
      t.integer :fee

      t.timestamps
    end
  end
end
