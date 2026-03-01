FactoryBot.define do
  factory :cart, class: Cart do
    total_price { 0.0 }
    last_interaction_at { Time.current }
  end
end
