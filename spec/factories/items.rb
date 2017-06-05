FactoryGirl.define do

  sequence :supplier_url do |n|
    "http://localhost/products/#{n}"
  end

  factory :list do
    name {Faker::Lorem.word }
  end
  factory :item do
    title { Faker::Commerce.product_name }
    association :list
  end

  factory :supplier do
    parser_class 'PriceList::Parser::Dummy'
    url          { generate(:supplier_url) }
    association :item
  end

  factory :item_price do
    price       { (rand * 10).round(2) }
    stock_state {['available', 'out of stock'].shuffle.first}
    created_at  { (Date.parse('2017-01-01')..Date.parse('2017-06-06')).to_a.shuffle.first}
    association :item
    association :supplier
  end
end
