class Activity < ActiveRecord::Base

  include ActivityStereotype
  
  # If this is a recurring activity, it belongs to an +ActivityFactory+.
  # This leaves room for updating all linked +Activity+ records in future development.
  belongs_to :activity_factory

  accepts_nested_attributes_for :activity_factory

end
