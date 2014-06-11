FactoryGirl.define do
  factory :session do
    association :user, factory: :user, strategy: :build
  end
end
