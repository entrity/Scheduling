class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.references :activity_factory

      t.string :name
      t.text :description

      t.datetime :start
      t.datetime :finish

      t.integer :bookings_available, default:0
      t.decimal :price, precision:6, scale:2, default:0

      t.boolean :deleted, default:false

      t.timestamps
    end
  end
end
