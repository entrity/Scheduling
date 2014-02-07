require 'spec_helper'

describe ActivityFactory do
  let(:af){ ActivityFactory.new days_of_week:0, days_of_month:1, months_of_year:0 }

  describe '#sunday' do
    it 'returns truthy value corresponding to bit 0 of days_of_week' do
      af.sunday.should == false
      af.days_of_week += (1<<0)
      af.sunday.should == true
    end
  end

  describe '#monday' do
    it 'returns truthy value corresponding to bit 1 of days_of_week' do
      af.monday.should == false
      af.days_of_week += (1<<1)
      af.monday.should == true
    end
  end

  describe '#saturday' do
    it 'returns truthy value corresponding to bit 6 of days_of_week' do
      af.saturday.should == false
      af.days_of_week += (1<<6)
      af.saturday.should == true
    end
  end

  describe '#sunday=' do
    it 'sets bit 0 of days_of_week' do
      af.days_of_week.should == 0
      af.sunday = true
      (af.days_of_week & (1<<0)).should > 0
      af.days_of_week.to_s(2)[-1].should == '1'
      af.days_of_week.should == 1
      af.sunday.should == true
    end
  end

  describe '#saturday=' do
    it 'sets bit 6 of days_of_week' do
      af.days_of_week.should == 0
      af.saturday = true
      (af.days_of_week & (1<<6)).should > 0
      af.days_of_week.should == 64
      af.saturday.should == true
    end
  end

  describe 'days_of_week bitwise accessors and mutators' do
    it 'provides expected behaviour when used in multiplicity' do
      af.monday = true
      af.days_of_week.should == (1<<1)
      af.sunday.should == false
      af.monday.should == true
      af.tuesday.should == false
      af.wednesday.should == false
      af.thursday.should == false
      af.friday.should == false
      af.sunday.should == false
      af.monday = true
      af.monday = true
      af.days_of_week.should == (1<<1)
      af.tuesday = true
      af.thursday = true
      af.monday = false
      af.sunday = false
      af.days_of_week.should == ((1<<2)|(1<<4))
      af.sunday.should == false
      af.monday.should == false
      af.tuesday.should == true
      af.wednesday.should == false
      af.thursday.should == true
      af.friday.should == false
      af.sunday.should == false
    end
  end

  describe 'number-based convencience function:' do
    let(:af){ ActivityFactory.new days_of_week:1, days_of_month:0, months_of_year:0 }

    describe '#days_of_month=' do
      context 'when given a Fixnum' do
        it 'sets field value to arg value' do
          af.days_of_month.should == 0
          af.days_of_month = 155
          af.days_of_month.should == 155
        end
      end
      context 'when given an Array of Fixnum' do
        it 'sets field bits from arg values' do
          af.days_of_month.should == 0
          af.days_of_month = [1,5,3,7,19]
          af.days_of_month.should == 0b10000000000010101010
        end
      end
    end

    describe '#days_of_month_array' do
      it 'returns array with numbers for bits set on :days_of_month' do
        af.days_of_month_array.should be_a Array
        af.days_of_month_array.should be_empty
        af.days_of_month = 0b10000000000010101010
        af.days_of_month_array.should == [1,3,5,7,19]
      end
    end
  end

  describe '#schedule_activities' do
    let(:start)     { DateTime.new 1999, 3, 31, 9, 0, 0 }
    let(:end_date)  { Date.new 2000, 1, 3 }
    let(:duration)  { 3.hours }
    let(:days_of_week)    { 0b1001100 }
    let(:days_of_month)   { 0b11000100 }
    let(:months_of_year)  { 0b10000100010 }
    let(:af){ FactoryGirl::build :activity_factory, id:14, days_of_week:days_of_week, days_of_month:days_of_month, months_of_year:months_of_year, name:'LAN Party', description:'Party hard',vendor_name:'Linus Torvalds', start:start, end_date:end_date}

    before do
      Timecop.freeze(Date.new 1999, 2, 15)
    end

    context 'when :days_of_week present but :days_of_month absent' do
      let(:days_of_month){ nil }
      it 'makes expected records' do
        expect{ af.schedule_activities }.to change(Activity, :count).by(27)
        activities = Activity.where(activity_factory_id:14)
        activities.all?{|a| a.start.tuesday? || a.start.wednesday? || a.start.saturday? }.should == true
        activities.all?{|a| [1,5,10].include? a.start.month }.should == true
      end
    end
    context 'when :days_of_week absent but :days_of_month present' do
      let(:days_of_week){ nil }
      it 'makes expected records' do
        af.schedule_activities
        Activity.where(activity_factory_id:14).map{|a| a.start.utc }.should == [
          Time.utc(1999, 5, 2, 9, 0, 0), # may 2 2000
          Time.utc(1999, 5, 6, 9, 0, 0), # may 6 1999
          Time.utc(1999, 5, 7, 9, 0, 0), # may 7 1999
          Time.utc(1999, 10, 2, 9, 0, 0), # oct 2 1999
          Time.utc(1999, 10, 6, 9, 0, 0), # oct 6 1999
          Time.utc(1999, 10, 7, 9, 0, 0), # oct 7 1999
          Time.utc(2000, 1, 2, 9, 0, 0), # jan 2 2000
        ]
      end
    end
    context 'when :days_of_week and :days_of_month absent' do
      let(:days_of_week){ nil }
      let(:days_of_month){ nil }
      it 'should not create any Activities' do
        expect{ af.schedule_activities }.to raise_error
      end
    end
  end

end
