# Patch for Contact model to add required field validation
# Validates: Nachname (last_name), Ort (city), Kanton (region), PLZ (postcode)

Contact.class_eval do
  validate :validate_contact_required_fields

  def validate_contact_required_fields
    # Nachname (last_name) - built-in field
    # Only validate last_name for people, not for companies
    if !is_company && last_name.blank?
      errors.add(:last_name, "darf nicht leer sein")
    end
    
    # Address fields (Ort, Kanton, PLZ) - from address association
    if address.present?
      # Ort (city)
      if address.city.blank?
        errors.add(:base, "Ort darf nicht leer sein")
      end
      
      # Kanton (region) 
      if address.region.blank?
        errors.add(:base, "Kanton darf nicht leer sein")
      end
      
      # PLZ (postcode)
      if address.postcode.blank?
        errors.add(:base, "PLZ darf nicht leer sein")
      end
    else
      # No address present at all
      errors.add(:base, "Adresse mit Ort, Kanton und PLZ muss angegeben werden")
    end
  end
end

# Patch for Address model to change display order (PLZ before Ort)
Address.class_eval do
  def post_address
    # Custom format: PLZ before Ort (postcode before city)
    address_lines = []
    
    # Street lines
    address_lines << street1 unless street1.blank?
    address_lines << street2 unless street2.blank?
    
    # PLZ + Ort (postcode + city) line
    plz_ort_line = []
    plz_ort_line << postcode unless postcode.blank?
    plz_ort_line << city unless city.blank?
    address_lines << plz_ort_line.join(' ') unless plz_ort_line.empty?
    
    # Region (Kanton)
    address_lines << region unless region.blank?
    
    # Country
    address_lines << country unless country.blank?
    
    address_lines.join("\n")
  end
  
  def to_s
    # Also update the to_s method for consistency (used in other places)
    parts = []
    parts << street1 unless street1.blank?
    parts << street2 unless street2.blank?
    
    # PLZ + Ort together
    if !postcode.blank? || !city.blank?
      plz_ort = [postcode, city].reject(&:blank?).join(' ')
      parts << plz_ort unless plz_ort.blank?
    end
    
    parts << region unless region.blank?
    parts << country unless country.blank?
    parts.join(', ')
  end
end

# Log that the patch was loaded
Rails.logger.info "Contact validation patch loaded for Contact model" 