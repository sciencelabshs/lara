FactoryGirl.define do
  sequence(:default_text) { Faker::Lorem.sentence(8) }

  factory :open_response, :class=> Embeddable::OpenResponse do |f|
  end
end

