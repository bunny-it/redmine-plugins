# Patch for Issue model to add household validation
# Placed in plugin root to avoid Zeitwerk autoloading issues

Issue.class_eval do
  validate :validate_household_members
  
  # Test method to verify patch is applied
  def household_validation_patch_applied?
    true
  end

  def validate_household_members
    # Try different ways to access custom field values
    frauen = custom_field_value(8)
    maenner = custom_field_value(9) 
    kinder = custom_field_value(10)
    
    # Alternative approach if custom_field_value doesn't work
    if frauen.nil? && maenner.nil? && kinder.nil?
      cf_values = custom_field_values
      frauen = cf_values.detect { |v| v.custom_field_id == 8 }&.value
      maenner = cf_values.detect { |v| v.custom_field_id == 9 }&.value
      kinder = cf_values.detect { |v| v.custom_field_id == 10 }&.value
    end
    
    # Check if all three fields are blank (empty string, nil, or contain only whitespace)
    frauen_blank = frauen.blank? || frauen.to_s.strip.empty?
    maenner_blank = maenner.blank? || maenner.to_s.strip.empty?
    kinder_blank = kinder.blank? || kinder.to_s.strip.empty?
    
    if frauen_blank && maenner_blank && kinder_blank
      errors.add(:base, "Mindestens eines der Felder: 'Anzahl Frauen im Haushalt', 'Anzahl Männer im Haushalt', oder 'Anzahl Kinder im Haushalt' muss ausgefüllt werden.")
    end
  end
end

# Log that the patch was loaded
Rails.logger.info "Household validation patch loaded for Issue model" 