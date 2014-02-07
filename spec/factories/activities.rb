FactoryGirl.define do
  factory :activity do
    name 'name string'
    description 'desc string'
    start { 5.hours.from_now }
    finish { 7.hours.from_now }
    after(:initialize) do |rec, evaluator|
      if rec.finish.nil? or rec.finish < rec.start
        rec.finish = rec.start + 2.hours
      end
    end
    before(:create) do |rec, evaluator|
      if rec.finish.nil? or rec.finish < rec.start
        rec.finish = rec.start + 2.hours
      end
    end
  end
end
