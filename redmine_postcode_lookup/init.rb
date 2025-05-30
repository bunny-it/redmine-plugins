require 'redmine'
require_relative 'lib/redmine_postcode_lookup/hooks'

Redmine::Plugin.register :redmine_postcode_lookup do
  name        'Redmine Postcode Lookup'
  author      'Alexis Xevelonakis'
  description 'Automatically fills the municipality (Ort) when entering a Swiss postal code using a chzip table.'
  version     '1.0.2'
  settings    default: {}, partial: 'settings/postcode_lookup_settings'
end
