FactoryGirl.define do
  factory :activity do
    name 'name string'
    description 'desc string'
    start { 5.hours.from_now }
    finish { 7.hours.from_now }
  end
end
