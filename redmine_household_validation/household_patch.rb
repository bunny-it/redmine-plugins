# Patch for Issue model to add household validation
# Placed in plugin root to avoid Zeitwerk autoloading issues

Issue.class_eval do
  validate :validate_household_members
  
  # Test method to verify patch is applied
  def household_validation_patch_applied?
    true
  end

  def validate_household_members
    # Only validate household fields for specific projects
    return unless should_validate_household_fields?
    
    # Skip validation if this is just a comment/note update
    return if only_adding_comment?
    
    # Skip validation if the household custom fields don't exist for this project/tracker
    return unless household_custom_fields_available?
    
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
  
  private
  
  def should_validate_household_fields?
    return false unless project
    
    # List of project identifiers where household validation should apply
    # Add "fallbearbeitung" and any subprojects that need this validation
    allowed_project_identifiers = [
      'fallbearbeitung',
      'beratung',  # Add any other project identifiers as needed
      # Add more project identifiers here if needed
    ]
    
    # Check if current project or any of its ancestors is in the allowed list
    current_project = project
    while current_project
      if allowed_project_identifiers.include?(current_project.identifier&.downcase)
        Rails.logger.info "Household validation enabled for project: #{current_project.identifier}"
        return true
      end
      current_project = current_project.parent
    end
    
    Rails.logger.info "Household validation skipped for project: #{project.identifier}"
    false
  end
  
  def only_adding_comment?
    # Check if this is only a comment/journal update by examining what's changed
    if persisted? # existing issue
      # Check if only notes or private_notes have been added
      # The issue itself hasn't changed if no substantial fields are dirty
      changed_attrs = changed_attributes.keys
      
      # Remove attributes that are always updated (like updated_on, etc.)
      substantial_changes = changed_attrs - ['updated_on', 'updated_at', 'lock_version']
      
      # If no substantial changes, this is likely just a comment
      return substantial_changes.empty?
    end
    
    # For new issues, always validate
    false
  end
  
  def household_custom_fields_available?
    return true unless tracker # If no tracker, let validation proceed
    
    # Check if the household custom fields (8, 9, 10) are available for this tracker
    household_field_ids = [8, 9, 10]
    available_custom_field_ids = tracker.custom_fields.pluck(:id)
    
    # At least one household field should be available
    has_household_fields = (household_field_ids & available_custom_field_ids).any?
    
    unless has_household_fields
      Rails.logger.info "Household validation skipped - no household custom fields available for tracker: #{tracker.name}"
    end
    
    has_household_fields
  end
end

# Log that the patch was loaded
Rails.logger.info "Household validation patch loaded for Issue model" 