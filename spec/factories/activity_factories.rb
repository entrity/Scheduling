FactoryGirl.define do
  factory :activity_factory do
    name 'name string'
    description 'desc string'
    start_date { Date.today }
    start_time { 5.hours.from_now }
    duration   { 3.hours }
    days_of_week 3
    days_of_month 14
  end
end
