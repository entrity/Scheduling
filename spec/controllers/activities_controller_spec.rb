require 'spec_helper'

describe ActivitiesController do

  describe '#index' do
    it 'returns 200' do
      get :index, format:'json'
      response.status.should == 200
    end
    it 'renders valid JSON' do
      get :index, format:'json'
      expect{ JSON.parse response.body }.to_not raise_error
    end
    context 'with data in db' do
      before do
        FactoryGirl::create :activity, start:1.days.ago, finish:(1.days.ago+2.hours)
        FactoryGirl::create :activity, start:1.days.from_now
        FactoryGirl::create :activity, start:3.days.from_now
        FactoryGirl::create :activity, start:5.days.from_now
        FactoryGirl::create :activity, start:7.days.from_now
      end
      it 'outputs items which fall within range, when no params specified' do 
        get :index, format:'json'
        activities = JSON.parse response.body
        activities.length.should == 4
        activities.all?{|a| a['start'] >= Time.now || a['finish'] <= Time.now }.should == true
      end
      it 'omits items which have started but not finished in given range' do
        start = (1.days.ago + 1.hours)
        get :index, format:'json', start:start
        activities = JSON.parse response.body
        activities.length.should == 4
        activities.all?{|a| a['start'] >= start || a['finish'] <= start }.should == true
      end
      it 'includes past items if indicated' do
        start = (1.days.ago - 1.hours)
        get :index, format:'json', start:start
        activities = JSON.parse response.body
        activities.length.should == 5
        activities.all?{|a| a['start'] >= start || a['finish'] <= start }.should == true
      end
      it 'omits items that fall after params[:finish]' do
        start = 2.days.ago
        finish = 2.days.from_now
        get :index, format:'json', start:start, finish:finish
        activities = JSON.parse response.body
        activities.length.should == 2
        activities.all?{|a| a['start'] >= start || a['finish'] <= start }.should == true
      end
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

      it 'does not create ActivityFactory record' do
        expect{ post :create, params }.to change(ActivityFactory, :count).by(0)
      end
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