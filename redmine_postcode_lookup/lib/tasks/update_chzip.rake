require 'net/http'
namespace :redmine do
  namespace :postcode_lookup do
    desc 'Fetch latest Swiss chzip JSON and populate database'
    task update_db: :environment do
      url = 'https://znerol.github.io/chzip-js/data/all.json'
      puts "Fetching #{url}..."
      response = Net::HTTP.get_response(URI(url))
      abort("Failed to fetch chzip data: #{response.code}") unless response.is_a?(Net::HTTPSuccess)
      records = JSON.parse(response.body)

      # Clear existing data and bulk-insert new records
      Chzip.delete_all
      Chzip.insert_all(
        records.map { |rec| { zip: rec['zip'].to_i, cty: rec['cty'], reg: rec['reg'] } }
      )

      puts "Imported #{records.size} postal code records."
    end
  end
end