// Auto-populate municipality (Ort) and canton (Kanton) from Swiss PLZ
// Also supports reverse lookup: populate PLZ and Kanton from Ort
(function($) {
  $(function() {
    console.log('Postcode lookup script loaded - version with reverse lookup');
    
    // Function to find fields with multiple strategies
    function findFields() {
      var plzField = $();
      var ortField = $();
      var kantField = $();
      
      // Strategy 1: Placeholder text (German and English)
      plzField = plzField.add($('input[placeholder*="PLZ"], input[placeholder*="Postcode"], input[placeholder*="postcode"]'));
      ortField = ortField.add($('input[placeholder*="Ort"], input[placeholder*="City"], input[placeholder*="city"], input[placeholder*="Stadt"]'));
      kantField = kantField.add($('input[placeholder*="Kanton"], input[placeholder*="Region"], input[placeholder*="region"], input[placeholder*="State"]'));
      
      // Strategy 2: CSS classes
      plzField = plzField.add($('input.postcode'));
      ortField = ortField.add($('input.city'));
      kantField = kantField.add($('input.region'));
      
      // Strategy 3: Custom field inputs by ID pattern (for ticket forms)
      plzField = plzField.add($('input[id*="custom_field_values_5"]')); // Custom field 5 = PLZ
      ortField = ortField.add($('input[id*="custom_field_values_6"]')); // Custom field 6 = Ort  
      kantField = kantField.add($('input[id*="custom_field_values_7"]')); // Custom field 7 = Kanton
      
      // Strategy 4: Field names
      plzField = plzField.add($('input[name*="postcode"], #address_postcode, #contact_address_attributes_postcode'));
      ortField = ortField.add($('input[name*="city"], #address_city, #contact_address_attributes_city'));
      kantField = kantField.add($('input[name*="region"], #address_region, #contact_address_attributes_region'));
      
      // Strategy 5: Label-based approach for backward compatibility
      var plzLabel = $('label').filter(function() { 
        var text = $(this).text().trim();
        return text.startsWith('PLZ') || text.includes('Postcode') || text.includes('postcode');
      });
      var ortLabel = $('label').filter(function() { 
        var text = $(this).text().trim();
        return text.startsWith('Ort') || text.includes('City') || text.includes('city') || text.includes('Stadt');
      });
      var kantLabel = $('label').filter(function() { 
        var text = $(this).text().trim();
        return text.startsWith('Kanton') || text.includes('Region') || text.includes('region') || text.includes('State');
      });
      
      if (plzLabel.length) plzField = plzField.add($('#' + plzLabel.attr('for')));
      if (ortLabel.length) ortField = ortField.add($('#' + ortLabel.attr('for')));
      if (kantLabel.length) kantField = kantField.add($('#' + kantLabel.attr('for')));
      
      // Strategy 6: Look for any input that might be address-related
      $('input[type="text"]').each(function() {
        var $input = $(this);
        var id = $input.attr('id') || '';
        var name = $input.attr('name') || '';
        var placeholder = $input.attr('placeholder') || '';
        var label = $('label[for="' + id + '"]').text() || '';
        
        var allText = (id + ' ' + name + ' ' + placeholder + ' ' + label).toLowerCase();
        
        if (allText.includes('plz') || allText.includes('postcode') || allText.includes('postal')) {
          plzField = plzField.add($input);
        }
        if (allText.includes('ort') || allText.includes('city') || allText.includes('stadt') || allText.includes('municipality')) {
          ortField = ortField.add($input);
        }
        if (allText.includes('kanton') || allText.includes('region') || allText.includes('state') || allText.includes('canton')) {
          kantField = kantField.add($input);
        }
      });
      
      // Remove duplicates
      plzField = plzField.filter(':visible').first();
      ortField = ortField.filter(':visible').first();
      kantField = kantField.filter(':visible').first();
      
      return { plz: plzField, ort: ortField, kant: kantField };
    }
    
    var fields = findFields();
    var plzField = fields.plz;
    var ortField = fields.ort;
    var kantField = fields.kant;
    
    console.log('Field detection results:', {
      plz: plzField.length + ' fields found',
      ort: ortField.length + ' fields found', 
      kant: kantField.length + ' fields found'
    });
    
    // Log all found fields for debugging
    if (plzField.length) {
      console.log('PLZ field found:', plzField[0], 'ID:', plzField.attr('id'), 'Name:', plzField.attr('name'), 'Placeholder:', plzField.attr('placeholder'));
    }
    if (ortField.length) {
      console.log('Ort field found:', ortField[0], 'ID:', ortField.attr('id'), 'Name:', ortField.attr('name'), 'Placeholder:', ortField.attr('placeholder'));
    }
    if (kantField.length) {
      console.log('Kant field found:', kantField[0], 'ID:', kantField.attr('id'), 'Name:', kantField.attr('name'), 'Placeholder:', kantField.attr('placeholder'));
    }

    // Setup PLZ → Ort/Kanton lookup (existing functionality)
    if (plzField.length) {
      console.log('Setting up postcode lookup on field:', plzField[0]);

      plzField.on('blur keyup', function() {
        var plz = $(this).val();
        if (!plz || plz.length < 4) return;
        
        console.log('Looking up postcode:', plz);
        
        $.getJSON('/postcode_lookup/' + plz)
          .done(function(data) {
            console.log('Postcode lookup result:', data);
            
            if (data.municipality && ortField.length) {
              console.log('Setting Ort field to:', data.municipality);
              ortField.val(data.municipality);
              ortField.trigger('change');
              ortField.trigger('input');
            }
            
            if (data.region && kantField.length) {
              console.log('Setting Kant field to:', data.region);
              kantField.val(data.region);
              kantField.trigger('change');
              kantField.trigger('input');
            }
          })
          .fail(function(xhr, status, error) {
            console.warn('Postcode lookup failed for', plz, 'Error:', error);
          });
      });
    } else {
      console.warn('PLZ field not found for postcode lookup');
    }

    // Setup Ort → PLZ/Kanton reverse lookup (new functionality)
    if (ortField.length) {
      console.log('Setting up reverse lookup on Ort field:', ortField[0]);

      ortField.on('blur', function() {
        var ort = $(this).val().trim();
        if (!ort || ort.length < 2) {
          console.log('Ort value too short or empty:', ort);
          return;
        }
        
        console.log('Starting reverse lookup for city:', ort);
        
        $.ajax({
          url: '/city_lookup',
          method: 'POST',
          data: { city: ort },
          dataType: 'json'
        })
          .done(function(data) {
            console.log('City reverse lookup result:', data);
            
            if (data.postcode && plzField.length) {
              console.log('Setting PLZ field to:', data.postcode, '(replacing existing value)');
              plzField.val(data.postcode);
              plzField.trigger('change');
              plzField.trigger('input');
            }
            
            if (data.region && kantField.length) {
              console.log('Setting Kanton field to:', data.region, '(replacing existing value)');
              kantField.val(data.region);
              kantField.trigger('change');
              kantField.trigger('input');
            }
            
            // Update the Ort field with the exact municipality name from database
            if (data.municipality && data.municipality !== ort) {
              console.log('Updating Ort field with exact name:', data.municipality);
              ortField.val(data.municipality);
              ortField.trigger('change');
              ortField.trigger('input');
            }
          })
          .fail(function(xhr, status, error) {
            console.warn('City reverse lookup failed for', ort, 'Error:', error, 'Status:', status);
            if (xhr.responseJSON) {
              console.warn('Response:', xhr.responseJSON);
            }
          });
      });
    } else {
      console.warn('Ort field not found for reverse lookup');
    }
    
    // Also try to setup after a delay in case fields are loaded dynamically
    setTimeout(function() {
      var newFields = findFields();
      if (newFields.ort.length && !ortField.length) {
        console.log('Found Ort field after delay, setting up reverse lookup');
        ortField = newFields.ort;
        // Setup the same event handler
        ortField.on('blur', function() {
          var ort = $(this).val().trim();
          if (!ort || ort.length < 2) return;
          
          console.log('Looking up city (delayed setup):', ort);
          
          $.ajax({
            url: '/city_lookup',
            method: 'POST',
            data: { city: ort },
            dataType: 'json'
          })
            .done(function(data) {
              console.log('City reverse lookup result (delayed):', data);
              
              if (data.postcode && newFields.plz.length) {
                console.log('Setting PLZ field to:', data.postcode, '(delayed setup)');
                newFields.plz.val(data.postcode);
                newFields.plz.trigger('change');
              }
              
              if (data.region && newFields.kant.length) {
                console.log('Setting Kanton field to:', data.region, '(delayed setup)');
                newFields.kant.val(data.region);
                newFields.kant.trigger('change');
              }
              
              if (data.municipality && data.municipality !== ort) {
                console.log('Updating Ort field with exact name:', data.municipality, '(delayed setup)');
                ortField.val(data.municipality);
                ortField.trigger('change');
              }
            })
            .fail(function(xhr, status, error) {
              console.warn('City reverse lookup failed (delayed):', error);
            });
        });
      }
    }, 2000);
  });
})(jQuery);
