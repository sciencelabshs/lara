# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  # Name is defined in the LightweightActivity factory
  sequence(:page_sidebar) { |n| Faker::Lorem.sentences(4).join(" ") }
  sequence(:page_text) { |n| Faker::Lorem.sentences(6).join(" ") }

  factory :page, :class => InteractivePage do
    name { generate(:name) }
    text { generate(:page_text) }
    sidebar { generate(:page_sidebar) }
    show_introduction 1
    show_sidebar 1
    show_interactive 1
    show_info_assessment 1
  end
end
