module RedmineJournalUpdatedDate
  module Hooks
    class JournalHooks < Redmine::Hook::ViewListener
      # Add JavaScript to replace "vor x Tagen aktualisiert" with actual date
      def view_layouts_base_html_head(context = {})
        return unless context[:controller].class.name == 'IssuesController'
        
        javascript_tag <<-JS
          $(document).ready(function() {
            console.log('Journal Updated Date Plugin loaded');
            
            // Function to replace relative dates with absolute dates
            function replaceRelativeDatesWithAbsolute() {
              console.log('Running replaceRelativeDatesWithAbsolute');
              
              // Look for text containing "aktualisiert" (updated)
              $('*').contents().filter(function() {
                return this.nodeType === 3 && 
                       (this.textContent.includes('aktualisiert') || 
                        this.textContent.includes('bearbeitet'));
              }).each(function() {
                var textNode = this;
                var text = textNode.textContent;
                console.log('Found text with aktualisiert/bearbeitet:', text);
                
                // Check for German relative date patterns
                var relativePattern = /vor\\s+(\\d+)\\s+(Tag|Tagen|Stunde|Stunden|Minute|Minuten)\\s+(aktualisiert|bearbeitet)/i;
                if (relativePattern.test(text)) {
                  console.log('Found relative date pattern in:', text);
                  
                  // Find parent elements that might have title attributes
                  var parentElement = $(textNode).parent();
                  var titleAttr = null;
                  
                  // Check current element and ancestors for title attribute
                  parentElement.parents().addBack().each(function() {
                    var currentTitle = $(this).attr('title');
                    if (currentTitle && currentTitle.match(/\\d{2}\\.\\d{2}\\.\\d{4}/)) {
                      titleAttr = currentTitle;
                      console.log('Found title attribute:', titleAttr);
                      return false; // Break the loop
                    }
                  });
                  
                  // If we found a title with a date, extract and use it
                  if (titleAttr) {
                    var dateMatch = titleAttr.match(/(\\d{2}\\.\\d{2}\\.\\d{4}(?:\\s+\\d{2}:\\d{2})?)/);
                    if (dateMatch) {
                      var actualDate = dateMatch[1];
                      console.log('Extracted date:', actualDate);
                      
                      // Replace the relative date with absolute date
                      var newText = text.replace(relativePattern, 'am ' + actualDate + ' $3');
                      console.log('Replacing text:', text, ' -> ', newText);
                      textNode.textContent = newText;
                    }
                  }
                }
              });
              
              // Also check specific elements that commonly contain these dates
              $('.journal .author, .journal h4, .history .author').each(function() {
                var element = $(this);
                var text = element.text();
                console.log('Checking element text:', text);
                
                var relativePattern = /vor\\s+(\\d+)\\s+(Tag|Tagen|Stunde|Stunden|Minute|Minuten)\\s+(aktualisiert|bearbeitet)/i;
                if (relativePattern.test(text)) {
                  console.log('Found relative date in element:', text);
                  
                  var titleAttr = element.attr('title') || element.find('[title]').first().attr('title');
                  
                  // Also check parent elements
                  if (!titleAttr) {
                    element.parents().each(function() {
                      var currentTitle = $(this).attr('title');
                      if (currentTitle && currentTitle.match(/\\d{2}\\.\\d{2}\\.\\d{4}/)) {
                        titleAttr = currentTitle;
                        return false;
                      }
                    });
                  }
                  
                  if (titleAttr) {
                    var dateMatch = titleAttr.match(/(\\d{2}\\.\\d{2}\\.\\d{4}(?:\\s+\\d{2}:\\d{2})?)/);
                    if (dateMatch) {
                      var actualDate = dateMatch[1];
                      var newText = text.replace(relativePattern, 'am ' + actualDate + ' $3');
                      console.log('Element replacement:', text, ' -> ', newText);
                      element.text(newText);
                    }
                  }
                }
              });
            }
            
            // Run immediately
            replaceRelativeDatesWithAbsolute();
            
            // Run after a short delay to catch dynamically loaded content
            setTimeout(replaceRelativeDatesWithAbsolute, 1000);
            
            // Run when new content is loaded via AJAX
            $(document).ajaxComplete(function() {
              console.log('AJAX completed, running date replacement');
              setTimeout(replaceRelativeDatesWithAbsolute, 500);
            });
            
            // Run periodically to catch any missed content
            setInterval(replaceRelativeDatesWithAbsolute, 3000);
          });
        JS
      end
    end
  end
end 