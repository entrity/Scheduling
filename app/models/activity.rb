class Activity < ActiveRecord::Base

  include ActivityStereotype
  
  # If this is a recurring activity, it belongs to an +ActivityFactory+.
  # This leaves room for updating all linked +Activity+ records in future development.
  belongs_to :activity_factory

  validates :name, presence:true, allow_nil:false
  validates :start, presence:true, allow_nil:false
  validates :finish, presence:true, allow_nil:false

  # Field for building an +ActivityFactory+, referenced in callback +create_activity_factory_wrapper+
  attr_accessor :recurrence

  accepts_nested_attributes_for :activity_factory

  before_create :create_activity_factory_wrapper

private

  # +before_create+ callback. It create an +ActivityFactory+ if a
  # +recurrence+ Hash has been set on this instance.
  def create_activity_factory_wrapper
    if recurrence
      create_activity_factory({
        # Fields copied straight from +Activity+ model
        name:name,
        description:description,
        vendor_id:vendor_id,
        vendor_name:vendor_name,
        bookings_available:bookings_available,
        price:price,
        start: start,
        # Fields inferred from +Activity+ model
        duration: (start && finish && finish - start)
      }.merge(recurrence) )
      return !activity_factory.new_record?
    end
  end

end
