module RedmineJournalUpdatedDate
  module Hooks
    class JournalHooks < Redmine::Hook::ViewListener
      # Simple JavaScript to replace relative date text with absolute dates from title attributes
      def view_layouts_base_html_head(context = {})
        return unless context[:controller].class.name == 'IssuesController'
        
        javascript_tag <<-JS
          $(document).ready(function() {
            // Simple function to replace relative dates with absolute dates from title attributes
            function replaceRelativeDates() {
              // Find all links with title attributes that contain dates (DD.MM.YYYY format)
              $('a[title]').each(function() {
                var $link = $(this);
                var title = $link.attr('title');
                var text = $link.text();
                
                // Check if title contains a date pattern (DD.MM.YYYY)
                if (title && title.match(/\\d{2}\\.\\d{2}\\.\\d{4}/)) {
                  // Check if text contains relative time expressions
                  if (text.match(/\\d+\\s+(Tag|Tagen|Woche|Wochen|Monat|Monaten|Jahr|Jahren)/)) {
                    // Extract just the date part from title (DD.MM.YYYY HH:MM -> DD.MM.YYYY)
                    var dateMatch = title.match(/(\\d{2}\\.\\d{2}\\.\\d{4})/);
                    if (dateMatch) {
                      $link.text(dateMatch[1]);
                    }
                  }
                }
              });
            }
            
            // Run immediately
            replaceRelativeDates();
            
            // Run after DOM changes (for AJAX content)
            $(document).ajaxComplete(function() {
              setTimeout(replaceRelativeDates, 100);
            });
          });
        JS
      end
    end
  end
end 