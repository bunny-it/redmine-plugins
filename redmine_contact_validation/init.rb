require 'redmine'

Redmine::Plugin.register :redmine_contact_validation do
  name 'Contact Validation Plugin'
  author 'Assistant'
  description 'Validates required contact fields and adds contextual buttons'
  version '1.0.0'
end

# Load patches after initialization
Rails.application.config.after_initialize do
  # Load the contact validation patch
  load File.expand_path('../contact_validation_patch.rb', __FILE__)
  
  # Load the library with hooks
  require_relative 'lib/redmine_contact_validation'
end 
