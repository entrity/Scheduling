class CreateActivityFactories < ActiveRecord::Migration
  def change
    create_table :activity_factories do |t|

      t.string :name
      t.text :description

      t.date :start_date
      t.date :finish_date
      t.time :start_time
      t.time :finish_time

      t.integer :days_of_week   # bitwise value for days of week when recurrence falls
      t.integer :days_of_month  # bitwise value for days of month when recurrence falls
      t.integer :months_of_year # bitwise value for months of year when recurrence falls
      t.integer :weeks_of_month # bitwise value for weeks of month when recurrence falls

      t.integer :bookings_available, default:0
      t.decimal :price, precision:6, scale:2, default:0

      t.boolean :deleted, default:false

      t.timestamps
    end
  end
end
