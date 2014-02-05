# This is a model for building recurring activities. It creates +Activity+ instances.
# +Activity+ creation is performed when an instance of this model is created and when 
# the schedule of the *whenever* gem dictates that it should be run.
#
# Most of the fields on this model concern recurrence of activities.
class ActivityFactory < ActiveRecord::Base

  # Override +destroy+ to prevent records from actually being deleted
  def destroy
    update_attributes! deleted:true
  end

private

  # == Pseudo Accessors/Mutators ==
  # The following code sets up convenience functions for the facility of anyone learning the API.
  # Bitwise operations performed on the following integral fields to get/set more human-useful data.
  #
  # For instance, calling +days_of_week_accessor(:sunday, 0)+ on this class creates the two functions:
  # - +sunday+
  # - +sunday=+
  # ...which can be used to get/set bits on the field +days_of_week+.

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

end
