module RedmineContactValidation
  module Hooks
    class ViewsContactsHook < Redmine::Hook::ViewListener
      render_on :view_contacts_before_actions,
                :partial => "contacts/contextual",
                :locals => { :contact => @contact, :project => @project }
      
      # Add JavaScript to inject required field indicators
      def view_layouts_base_html_head(context = {})
        return unless context[:controller].class.name == 'ContactsController'
        
        javascript_tag <<-JS
          $(document).ready(function() {
            // Add required indicator to Nachname field
            var nachnameLabel = $('label[for="contact_last_name"]');
            if (nachnameLabel.length > 0 && !nachnameLabel.find('.required').length) {
              nachnameLabel.append('<span class="required"> *</span>');
              $('#contact_last_name').attr('required', true);
            }
            
            // Add required indicator to PLZ field
            var plzField = $('#contact_address_attributes_postcode');
            if (plzField.length > 0) {
              plzField.attr('required', true);
              // Find the address container and add a label with required indicator
              var addressContainer = plzField.closest('p.address.postcode');
              if (addressContainer.length > 0 && !addressContainer.find('.required').length) {
                addressContainer.append('<span class="required" style="color: red; font-weight: bold; margin-left: 5px;">*</span>');
              }
              // Also update placeholder
              var currentPlaceholder = plzField.attr('placeholder');
              if (currentPlaceholder && !currentPlaceholder.includes('*')) {
                plzField.attr('placeholder', currentPlaceholder + ' *');
              }
            }
            
            // Add required indicator to Ort (City) field
            var ortField = $('#contact_address_attributes_city');
            if (ortField.length > 0) {
              ortField.attr('required', true);
              // Find the address container and add a label with required indicator
              var ortContainer = ortField.closest('p.address.city');
              if (ortContainer.length > 0 && !ortContainer.find('.required').length) {
                ortContainer.append('<span class="required" style="color: red; font-weight: bold; margin-left: 5px;">*</span>');
              }
              // Also update placeholder
              var currentPlaceholder = ortField.attr('placeholder');
              if (currentPlaceholder && !currentPlaceholder.includes('*')) {
                ortField.attr('placeholder', currentPlaceholder + ' *');
              }
            }
            
            // Add required indicator to Kanton (Region) field
            var kantonField = $('#contact_address_attributes_region');
            if (kantonField.length > 0) {
              kantonField.attr('required', true);
              // Find the address container and add a label with required indicator
              var kantonContainer = kantonField.closest('p.address.region');
              if (kantonContainer.length > 0 && !kantonContainer.find('.required').length) {
                kantonContainer.append('<span class="required" style="color: red; font-weight: bold; margin-left: 5px;">*</span>');
              }
              // Also update placeholder
              var currentPlaceholder = kantonField.attr('placeholder');
              if (currentPlaceholder && !currentPlaceholder.includes('*')) {
                kantonField.attr('placeholder', currentPlaceholder + ' *');
              }
            }
            
            // Handle the toggle function for company/person mode
            var originalTogglePerson = window.togglePerson;
            if (typeof originalTogglePerson === 'function') {
              window.togglePerson = function(element) {
                originalTogglePerson(element);
                
                // Re-add required indicators after toggle
                setTimeout(function() {
                  var nachnameLabel = $('label[for="contact_last_name"]');
                  if (nachnameLabel.length > 0 && !nachnameLabel.find('.required').length) {
                    nachnameLabel.append('<span class="required"> *</span>');
                  }
                }, 100);
              };
            }
          });
        JS
      end
    end
  end
end 