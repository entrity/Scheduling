class CreateBookings < ActiveRecord::Migration
  def change
    create_table :bookings do |t|
      t.string :name
      t.references :activity, index: true
      t.timestamps
    end
  end
end
