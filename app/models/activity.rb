class Activity < ActiveRecord::Base
  
  # If this is a recurring activity, it belongs to an +ActivityFactory+.
  # This leaves room for updating all linked +Activity+ records in future development.
  belongs_to :activity_factory

  accepts_nested_attributes_for :activity_factory

  # Override +destroy+ to prevent records from actually being deleted
  def destroy
    update_attributes! deleted:true
  end

end
