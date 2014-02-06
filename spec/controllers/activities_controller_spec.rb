require 'spec_helper'

describe ActivitiesController do

  describe '#index' do
    it 'returns 200' do
      pending
    end
    it 'renders valid JSON' do
      pending
    end
  end

  describe '#create' do
    let(:params) {{format:'json', activity:{name:'Shredding', vendor_name:'Eddie Van Halen', start:3.hours.from_now, finish:6.hours.from_now}}}

    shared_examples_for '#create' do
      it 'returns 201' do
        post :create, params
        response.status.should == 201
      end
      it 'creates a record' do
        expect{ post :create, params }.to change(Activity, :count).by(1)
      end
      it 'returns valid JSON' do
        post :create, params
        expect{ JSON.parse response.body }.to_not raise_error
      end
    end

    context 'without params for recurrence' do
      it_behaves_like '#create'
    end
    
    context 'with params for recurrence' do
      before do
        params[:activity][:recurrence] = {days_of_week:7, days_of_month:14, months_of_year:6, end_date:5.months.from_now}
      end

      it_behaves_like '#create'

      it 'creates ActivityFactory record' do
        expect{ post :create, params }.to change(ActivityFactory, :count).by(1)
      end

      it 'fails' do
        params[:activity][:recurrence] = {}
        expect{ post :create, params }.to_not change(Activity, :count)
        expect{ post :create, params }.to_not change(ActivityFactory, :count)
        response.status.should == 400
      end
    end
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