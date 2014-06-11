FactoryGirl.define do
  factory :form_field do
    association :form, factory: :form, strategy: :build
    kind { FormField::KINDS.sample }
    details { {} }

    factory :info_field do
      kind "info"
      details text: "# Form Information\nThis is a test form."
    end

    factory :address_field do
      kind "address"
      details question: "Enter your address", required: true
    end

    factory :short_answer_field do
      kind "short-answer"
      details question: "What is your favorite color?", label: "Answer", required: true
    end

    factory :long_answer_field do
      kind "long-answer"
      details question: "What is your quest?", label: "Answer", required: true
    end

    factory :single_choice_field do
      kind "single-choice"
      details question: "Which letter is your favorite?", required: true, choices: [
        { label: "A" }, { label: "B" }, { label: "C" }
      ]
    end

    factory :multiple_choice_field do
      kind "multiple-choice"
      details question: "Pick one or more letters you like.", required: true, choices: [
        { label: "A" }, { label: "B" }, { label: "C" }
      ]
    end
  end
end
