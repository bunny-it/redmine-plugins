require 'redmine'

Redmine::Plugin.register :redmine_contact_validation do
  name 'Contact Validation Plugin'
  author 'Assistant'
  description 'Validates required contact fields and adds contextual buttons'
  version '1.0.0'
end

# Load patches after initialization
Rails.application.config.after_initialize do
  # Only load the contact validation patch if Contact model is available
  if defined?(Contact)
    load File.expand_path('../contact_validation_patch.rb', __FILE__)
    Rails.logger.info "Contact validation patch loaded successfully"
  else
    Rails.logger.warn "Contact model not found, contact validation patch not loaded"
  end
  
  # Load the library with hooks
  require_relative 'lib/redmine_contact_validation'
end 
