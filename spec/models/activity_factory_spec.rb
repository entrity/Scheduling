require 'spec_helper'

describe ActivityFactory do
  let(:af){ ActivityFactory.new days_of_week:0 }

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

end
