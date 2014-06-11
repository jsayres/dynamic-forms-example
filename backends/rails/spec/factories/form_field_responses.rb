FactoryGirl.define do
  factory :form_field_response do
    association :form_response, factory: :form_response, strategy: :build
    association :form_field, factory: :form_field, strategy: :build, kind: FormField::KINDS.reject { |k| k == 'info' }.sample
    details { {} }

    factory :address_response do
      details { {
        addressLine1: Faker::Address.street_address,
        addressLine2: Faker::Address.secondary_address,
        city: Faker::Address.city,
        state: Faker::Address.state,
        zip: Faker::Address.zip
      } }
    end

    factory :short_answer_response do
      details { {answer: Faker::Lorem.sentence} }
    end

    factory :long_answer_response do
      details { {answer: Faker::Lorem.sentence} }
    end

    factory :single_choice_response do
      details { {answer: ["A", "B", "C"].sample} }
    end

    factory :multiple_choice_response do
      details { {
        answers: ["A", "B", "C"].map do |label|
          {label: label, selected: Random.rand > 0.5 }
        end
      } }
    end 
  end
end
