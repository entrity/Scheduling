require 'spec_helper'

describe ActivitiesController do
  let(:bookings_available){ 5 }
  let(:activity) { FactoryGirl.create :activity, bookings_available:bookings_available }

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
        expect{ post :create, params }.to change(Activity, :count).by( activities_ct )
      end
      it 'returns valid JSON' do
        post :create, params
        expect{ JSON.parse response.body }.to_not raise_error
      end
    end

    context 'without params for recurrence' do
      let(:activities_ct){ 1 }

      it_behaves_like '#create'

      it 'does not create ActivityFactory record' do
        expect{ post :create, params }.to change(ActivityFactory, :count).by(0)
      end

      it 'renders JSON Hash' do
        post :create, params
        output = JSON.parse response.body
        output.should be_a Hash
      end
    end
    
    context 'with params for recurrence' do
      let(:activities_ct){ 7 }

      before do
        Timecop.freeze(Date.new 2014, 1, 1)
        params[:activity][:recurrence] = {days_of_month:14, months_of_year:6, end_date:5.months.from_now}
      end

      it_behaves_like '#create'

      it 'creates ActivityFactory record' do
        expect{ post :create, params }.to change(ActivityFactory, :count).by(1)
      end

      it 'renders JSON array of 7 activities' do
        post :create, params
        output = JSON.parse response.body
        output.should be_a Array
        output.length.should == 7
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

  describe '#add_booking' do
    let(:params){ {format:'json', name:'Clarence Clemmons', id:activity.id} }

    context 'when bookings are available' do
      it 'decrements bookings_available on Activity' do
        post :add_booking, params
        activity.reload.bookings_available.should == 4
      end
      it 'creates a Booking record' do
        expect{ post :add_booking, params }.to change(Booking, :count).by(1)
      end
      it 'returns 201' do
        post :add_booking, params
        response.status.should == 201
      end
    end
    context 'when bookings are NOT available' do
      let(:bookings_available){ 0 }

      it 'creates no booking record' do
        expect{ post :add_booking, params }.to_not change(Booking, :count)
      end
      it 'does NOT decrement bookings_available on Activity' do
        post :add_booking, params
        activity.reload.bookings_available.should == 0
      end
      it 'returns 418' do
        post :add_booking, params
        response.status.should == 418
      end
    end
  end

  describe '#update' do
    let(:params) { { format:'json', id:activity.id, activity:{name:'colourless green ideas sleep furiously'} } }
    it 'does not create a record' do
      activity.save
      expect{put :update, params }.to_not change(Activity, :count)
    end
    it 'changes name (when given name param)' do
      activity.name.should_not == 'colourless green ideas sleep furiously' 
      put :update, params
      activity.reload.name.should == 'colourless green ideas sleep furiously' 
    end
  end

end