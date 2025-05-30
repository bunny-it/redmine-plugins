require 'redmine'
require_relative 'lib/redmine_view_customizations/hooks'

Redmine::Plugin.register :redmine_view_customizations do
  name        'Redmine View Customizations'
  author      'Alexis Xevelonakis'
  description 'Reorder tabs; show absolute timestamps; move Thema/Unterthema; restore contact autocomplete.'
  version     '0.1.1'
end
