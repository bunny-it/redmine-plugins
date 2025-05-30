# File: config/routes.rb
RedmineApp::Application.routes.draw do
  match '/postcode_lookup/:postcode', to: 'postcodes#lookup', via: :get
  match '/city_lookup', to: 'postcodes#reverse_lookup', via: :post
end