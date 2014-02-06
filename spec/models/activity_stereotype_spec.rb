require 'spec_helper'

shared_examples_for ActivityStereotype do

  describe '#denormalize_vendor_name' do
    it 'gets triggered by #save' do
      activity.stub(:denormalize_vendor_name)
      activity.should_receive :denormalize_vendor_name
      activity.save
    end
  end

  describe '#destroy' do
    it 'does not destroy a record' do
      expect{activity.destroy}.to_not change(activity.class, :count)
    end
    it 'sets deleted field' do
      activity.deleted.should == false
      activity.destroy
      activity.deleted.should == true
    end
  end

end

describe Activity do
  let(:activity){ FactoryGirl.create :activity }
  it_behaves_like ActivityStereotype
end

describe ActivityFactory do
  let(:activity){ FactoryGirl.create :activity_factory }
  it_behaves_like ActivityStereotype
end
