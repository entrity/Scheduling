require 'spec_helper'

describe ActivitiesController do

  describe '#create' do
  end

  describe '#destroy' do
    let(:activity){ FactoryGirl::create :activity }

    it 'sets deleted on Activity record' do
      delete :destroy, {id:activity.id, format:'json'}
      assigns(:activity).deleted.should == true
    end
    it 'does not remove a record from the db' do
      activity # call this so that the creation takes place before my 'expect' call
      expect{delete :destroy, {id:activity.id, format:'json'}}.to_not change(Activity, :count)
    end
    it 'returns 204 when given a valid id for a record' do
      delete :destroy, {id:activity.id, format:'json'}
      response.status.should == 204
    end
  end

end