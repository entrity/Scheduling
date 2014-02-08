class Booking < ActiveRecord::Base
  belongs_to :activity

  after_create :decrement_bookings_available

private

  def decrement_bookings_available
    activity.bookings_available -= 1
    activity.save
  end

end
