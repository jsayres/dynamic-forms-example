FactoryGirl.define do
  factory :form do
    number 1
    version 1
    name "Test Form"
    description "This is a test form."
    slug "slug"
    project { PROJECTS.keys.sample }
    association :user, factory: :user, strategy: :build
    published false
    current false
    locked false
  end
end
