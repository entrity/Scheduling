# This is a model for building recurring activities. It creates +Activity+ instances.
# +Activity+ creation is performed when an instance of this model is created and when 
# the schedule of the *whenever* gem dictates that it should be run.
#
# Most of the fields on this model concern recurrence of activities.
class ActivityFactory < ActiveRecord::Base

  include ActivityStereotype

  has_many :activities

  validates :name, presence:true, allow_nil:false
  validates :start_date, presence:true, allow_nil:false
  validates :start_time, presence:true, allow_nil:false
  validates :duration, presence:true, allow_nil:false
  validate  :require_recurrence_constraints

  # Override +destroy+ to prevent records from actually being deleted
  def destroy
    update_attributes! deleted:true
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

  def require_recurrence_constraints
    unless days_of_week.try(:>, 0) || days_of_month.try(:>, 0)
      errors.add :base, "Must supply days_of_week or days_of_month"
    end
  end

end
