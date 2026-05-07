class CreateHttpBins < ActiveRecord::Migration[8.1]
  def change
    create_table :http_bins do |t|
      t.string  :name, null: false
      t.string  :token, null: false
      t.text    :description
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :http_bins, :token, unique: true
  end
end
