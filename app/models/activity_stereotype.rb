module ActivityStereotype

  def self.included(base)
    base.before_save :denormalize_vendor_name
  end

  # Override +destroy+ to prevent records from actually being deleted
  def destroy
    update_attributes! deleted:true
  end

protected

  # This method anticipates the eventual creation of a +Vendor+ model, to which models
  # that mixin this module shall belong. 
  # Because no +Vendor+ class exists now, this function simply raises an error, but
  # after the implementation of +Vendor+, the +raise+ line can be removed from this
  # function.
  #
  # In a small project, I wouldn't deem necessary the denormalization of a +Vendor+ name onto 
  # models of this stereotype, but it would pay off if there were much indexing of models to be
  # done, and the project requirements sugested a vendor name field on the +Activity+ model.
  def denormalize_vendor_name
    self.vendor_name = vendor.try(:name) if vendor_id_changed?
  end

end