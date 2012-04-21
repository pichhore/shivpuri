namespace :db do
  desc 'Load missing zip codes using zips yml file'
  task :load_zip_codes => :environment do
    File.open("#{RAILS_ROOT}/db/data/zips.yml", 'r') do |file|
      YAML::load(file).each do |record|
        params = record[1]
        if Zip.find_by_zip(params["zip"]).nil?
          territory = Territory.find_by_reim_name(params.delete("territory"))
          county = County.find_by_name(params.delete("county"))
          Zip.create(params.merge({:territory_id => territory.id, :county_id => county.id}))
          puts ">> zip code #{params["zip"]} loaded successfully"
        end 
      end
    end
  end
end
