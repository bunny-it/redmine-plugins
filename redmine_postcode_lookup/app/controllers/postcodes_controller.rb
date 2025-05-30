# File: app/controllers/postcodes_controller.rb
class PostcodesController < ApplicationController
  # Removed deprecated 'unloadable'
  # Skip authentication for postcode lookup since it's just data lookup
  skip_before_action :check_if_login_required, :only => [:lookup, :reverse_lookup]
  skip_before_action :verify_authenticity_token, :only => [:reverse_lookup]
  
  def lookup
    zip = params[:postcode].to_i
    record = Chzip.find_by(zip: zip)
    if record
      # Ensure proper UTF-8 encoding
      municipality = record.cty.to_s.force_encoding('UTF-8')
      region = record.reg.to_s.force_encoding('UTF-8')
      
      # Log the data being returned
      Rails.logger.info "Postcode lookup for #{zip}: municipality='#{municipality}', region='#{region}'"
      
      render json: { municipality: municipality, region: region }
    else
      Rails.logger.warn "Postcode lookup failed: no record found for #{zip}"
      render json: { error: 'Not found' }, status: :not_found
    end
  end
  
  def reverse_lookup
    # Get city from POST parameters
    city = params[:city].to_s.strip
    
    record = nil
    
    Rails.logger.info "Starting reverse lookup for: '#{city}'"
    
    # Strategy 1: Try exact match first (case sensitive)
    record = Chzip.find_by(cty: city)
    if record
      Rails.logger.info "Found exact match: #{record.cty} (#{record.zip})"
      render_result(record, city)
      return
    end
    
    # Strategy 2: Case-insensitive exact match
    record = Chzip.where("LOWER(cty) = LOWER(?)", city).first
    if record
      Rails.logger.info "Found case-insensitive exact match: #{record.cty} (#{record.zip})"
      render_result(record, city)
      return
    end
    
    # Strategy 3: Try with different punctuation (. vs - vs space)
    variations = [
      city.gsub('.', '-'),
      city.gsub('-', '.'),
      city.gsub('.', ' '),
      city.gsub(' ', '.'),
      city.gsub('-', ' '),
      city.gsub(' ', '-')
    ].uniq.reject { |v| v == city }
    
    variations.each do |variant|
      record = Chzip.where("LOWER(cty) = LOWER(?)", variant).first
      if record
        Rails.logger.info "Found punctuation variant match: #{record.cty} (#{record.zip}) for variant '#{variant}'"
        render_result(record, city)
        return
      end
    end
    
    # Strategy 4: Smart partial matching - prefer longer input matches
    if city.length >= 3
      # Find all candidates that start with the input
      candidates = Chzip.where("LOWER(cty) LIKE LOWER(?)", "#{city}%").to_a
      
      if candidates.any?
        # Score candidates based on how well they match
        scored_candidates = candidates.map do |candidate|
          score = calculate_match_score(city, candidate.cty)
          { record: candidate, score: score }
        end
        
        # Sort by score (higher is better), then by postal code (lower is better for main cities)
        best_match = scored_candidates.sort_by { |c| [-c[:score], c[:record].zip] }.first
        
        if best_match[:score] > 0
          Rails.logger.info "Found smart partial match: #{best_match[:record].cty} (#{best_match[:record].zip}) with score #{best_match[:score]}"
          render_result(best_match[:record], city)
          return
        end
      end
    end
    
    # Strategy 5: Contains search for partial words (like "Gallen" finding "St. Gallen")
    if city.length >= 4
      candidates = Chzip.where("LOWER(cty) LIKE LOWER(?)", "%#{city}%")
                       .order('LENGTH(cty) ASC, zip ASC')
                       .limit(10)
      
      if candidates.any?
        # Prefer matches where the input is a complete word
        word_matches = candidates.select { |c| c.cty.downcase.split(/[\s\-\.]/).include?(city.downcase) }
        record = word_matches.first || candidates.first
        
        Rails.logger.info "Found contains match: #{record.cty} (#{record.zip})"
        render_result(record, city)
        return
      end
    end
    
    Rails.logger.warn "No match found for '#{city}'"
    render json: { error: 'Not found' }, status: :not_found
  end
  
  private
  
  def calculate_match_score(input, candidate)
    input_lower = input.downcase
    candidate_lower = candidate.downcase
    
    # Exact match gets highest score
    return 1000 if input_lower == candidate_lower
    
    # Exact match ignoring punctuation
    input_clean = input_lower.gsub(/[.\-\s]/, '')
    candidate_clean = candidate_lower.gsub(/[.\-\s]/, '')
    return 900 if input_clean == candidate_clean
    
    # Input is complete word in candidate
    words = candidate_lower.split(/[\s\-\.]/)
    return 800 if words.include?(input_lower)
    
    # Candidate starts with input and is not much longer
    if candidate_lower.start_with?(input_lower)
      length_ratio = input.length.to_f / candidate.length
      return (700 * length_ratio).to_i
    end
    
    # Input contains multiple words that match
    input_words = input_lower.split(/[\s\-\.]/)
    if input_words.length > 1
      matching_words = input_words.count { |word| candidate_lower.include?(word) }
      if matching_words > 0
        return 500 + (matching_words * 100)
      end
    end
    
    # Partial match
    if candidate_lower.include?(input_lower)
      return 300
    end
    
    0
  end
  
  def render_result(record, original_input)
    # Ensure proper UTF-8 encoding
    postcode = record.zip.to_s
    region = record.reg.to_s.force_encoding('UTF-8')
    municipality = record.cty.to_s.force_encoding('UTF-8')
    
    Rails.logger.info "Reverse lookup for '#{original_input}': postcode='#{postcode}', region='#{region}', municipality='#{municipality}'"
    
    render json: { postcode: postcode, region: region, municipality: municipality }
  end
end