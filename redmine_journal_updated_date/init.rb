require 'redmine'

Redmine::Plugin.register :redmine_journal_updated_date do
  name 'Journal Updated Date Plugin'
  author 'Assistant'
  description 'Displays updated_on date in journal entries'
  version '1.0.0'
end

# Load patches after initialization
Rails.application.config.after_initialize do
  # Load the journal view hooks
  require_relative 'lib/redmine_journal_updated_date'
end 