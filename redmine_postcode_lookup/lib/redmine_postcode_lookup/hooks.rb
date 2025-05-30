module RedminePostcodeLookup
  class Hooks < Redmine::Hook::ViewListener
    # Inject our JS into the HTML head
    def view_layouts_base_html_head(context = {})
      javascript_include_tag('postcode_lookup', plugin: 'redmine_postcode_lookup')
    end
  end
end
