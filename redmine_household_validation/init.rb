require 'redmine'

Redmine::Plugin.register :redmine_household_validation do
  name 'Redmine Household Validation'
  author 'Alexis Xevelonakis'
  description 'Validation for household member fields'
  version '0.0.1'
  requires_redmine :version_or_higher => '6.0.0'
end

Rails.application.config.after_initialize do
  if defined?(Issue)
    load File.expand_path('../household_patch.rb', __FILE__)
  else
    Rails.logger.warn "Issue model not found, household validation patch not loaded"
  end
end 
