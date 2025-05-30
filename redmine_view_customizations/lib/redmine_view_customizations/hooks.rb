module RedmineViewCustomizations
  class Hooks < Redmine::Hook::ViewListener
    # Inject our custom JS into the page head
    def view_layouts_base_html_head(context = {})
      javascript_include_tag('view_customizations', plugin: 'redmine_view_customizations').html_safe
    end
  end
end
