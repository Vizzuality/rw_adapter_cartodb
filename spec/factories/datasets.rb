FactoryGirl.define do
  factory :connector, class: 'Connector' do
    connector_name 'CartoDb test set'
    connector_format 0
    connector_url 'https://rschumann.cartodb.com/api/v2/sql?q=select%20*%20from%20public.carts_test_endoint'
    connector_provider 0
    connector_path 'rows'
  end

  factory :dataset, class: 'Dataset' do
    table_name 'carts_test_endoint'
    association :connector, factory: :connector
  end
end
