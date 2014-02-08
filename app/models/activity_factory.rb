# This is a model for building recurring activities. It creates +Activity+ instances.
# +Activity+ creation is performed when an instance of this model is created and when 
# the schedule of the *whenever* gem dictates that it should be run.
#
# Most of the fields on this model concern recurrence of activities.
class ActivityFactory < ActiveRecord::Base

  include ActivityStereotype

  has_many :activities

  validates :name, presence:true, allow_nil:false
  validates :start, presence:true, allow_nil:false
  validates :duration, presence:true, allow_nil:false
  validate  :require_recurrence_constraints

  after_create :schedule_activities

  # Override +destroy+ to prevent records from actually being deleted
  def destroy
    update_attributes! deleted:true
  end

  # Creates +Activity+ instances until +end_date+ or <tt>1.year.from_now</tt>
  # Fires as a callback +after_create+
  # - Schedules on a weekly basis if <tt>days_of_week > 0</tt>
  # - Else, schedules on a month basis if <tt>days_of_month > 0</tt>
  # - Else, raises error
  def schedule_activities
    raise StandardError, errors.full_messages unless valid?
    # Calc time of first activity and last activity within scheduling range (max 1 yr)
    today = Date.today
    schedule_finish = self.end_date || 1.year.from_now
    dt = DateTime.new today.year, today.month, today.day, start.hour, start.min, start.sec
    # Loop for one year
    while dt <= schedule_finish
      find_or_create_activity(dt) if meets_constraints?(dt)
      dt += 1.days
    end
  end

  # == Pseudo Accessors/Mutators ==
  # The following code sets up convenience functions for the facility of anyone learning the API.
  # Bitwise operations performed on the following integral fields to get/set more human-useful data.
  #
  # For instance, calling +days_of_week_accessor(:sunday, 0)+ on this class creates the two functions:
  # - +sunday+
  # - +sunday=+
  # ...which can be used to get/set bits on the field +days_of_week+.

  # Define name-based convenience functions for days_of_week
  [:sunday, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday].each_with_index do |name, bit|

    # Define getter, which returns boolean if recurrence is set for given day of week
    define_method name do
      self.days_of_week ||= 0
      (self.days_of_week & (1<<bit)) != 0
    end

    # Define setter
    define_method "#{name}=" do |value|
      if value
        self.days_of_week |= (1<<bit)
      else
        self.days_of_week &= ~(1<<bit)
      end
    end
  end

  # Define number-based convenience functions for days_of_week, days_of_month, and months_of_year
  [:days_of_week, :days_of_month, :months_of_year].each do |field|

    # Define getter, which returns an +Array+ of +Fixnum+
    define_method "#{field}_array" do
      bits = []
      bitmask = self[field]
      i = 0
      while bitmask > 0
        # last digit is 1 if bitmask is odd
        bits.push(i) if (bitmask % 2) > 0
        # bitshift bitmask
        bitmask = bitmask >> 1
        # increment i
        i += 1
      end
      bits
    end

    # Define setter, which behaves as normal unless the arg is an +Array+
    define_method "#{field}=" do |value|
      if value.is_a? Array
        # Set bits for all Fixnum in +value+ array
        self[field] = 0
        value.each{|bit| self[field] |= (1<<bit) }
      else
        # Default behaviour: write bitmask
        self[field] = value
      end
    end
  end

private

  # Returns true if given bit == 1 on +num+
  def bit_set? num, bit
    (num >> bit) % 2 == 1
  end

  # Returns true if +bitmask+ is nil or 0, which are considered wildcards.
  # Otherwise, returns true if the bit is set.
  def constraint_match? bitmask, bit
    bitmask.nil? || bitmask == 0 || bit_set?(bitmask, bit)
  end

  # Returns a DateTime for the given date falling between +schedule_start+
  # and +schedule_finish+.
  # Returns nil if Date is invalid or does not fall within range.
  def build_dt_in_range yr, mo, day, time
    if Date::valid_civil?(yr, mo, day)
      dt = DateTime.new(yr, mo, day, time.hour, time.min, time.sec) and
      return dt if dt >= schedule_start and dt <= schedule_finish
    end
  end

  # Find or create an activity whose +activity_factory_id+ matches this instance
  # and whose +start+ matches the argument +start_datetime+
  def find_or_create_activity(start_datetime)
    Activity.find_or_create_by({
      # Fields copied straight from +ActivityFactory+ model
      name:name,
      description:description,
      vendor_id:vendor_id,
      vendor_name:vendor_name,
      bookings_available:bookings_available,
      price:price,
      # Fields inferred from +ActivityFactory+ model
      activity_factory_id:self.id,
      start: start_datetime,
      finish: start_datetime + duration.seconds,
    })
  end

  def meets_constraints? datetime
    # months of year
    return false unless constraint_match? months_of_year, datetime.month
    # days of month
    return false unless constraint_match? days_of_month, datetime.day
    # days of week
    return false unless constraint_match? days_of_week, datetime.wday
    # ...constraints passed
    true
  end

  # Validation method
  def require_recurrence_constraints
    unless days_of_week.try(:>, 0) || days_of_month.try(:>, 0)
      errors.add :base, "Must supply days_of_week or days_of_month"
    end
  end

end
