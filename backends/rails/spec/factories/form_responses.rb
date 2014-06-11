FactoryGirl.define do
  factory :form_response do
    association :form, factory: :form, strategy: :build
    association :user, factory: :user, strategy: :build
  end
end
