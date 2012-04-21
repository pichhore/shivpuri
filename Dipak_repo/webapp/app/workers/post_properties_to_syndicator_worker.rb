class PostPropertiesToSyndicatorWorker
  @auth = {:username => SYND_APP['login'], :password => SYND_APP['password']}
  @queue = :post_properties_to_syndicator

  def self.perform
    
    SyndicateProperty.find_in_batches(:batch_size => 5) { |properties|
      properties_hash = {}
 
      properties.each do |property| 
        properties_hash["property_#{properties.index(property).to_s }".to_sym] = property.attributes
        @profile_sites = ProfileSite.sites_to_syndicate_for_profile(property.profile_id)
        sites = @profile_sites.map{|x| x.site_id}
        properties_hash["property_#{properties.index(property).to_s }".to_sym]["sites"] = sites
      end
      
      options = {
        :body => {
          :properties => properties_hash
        }
      }
    
      options.merge!({:basic_auth => @auth})
      response = HTTParty.post(SYNDICATION_URL + "syndicate", options)

      if Crack::XML.parse(response.body)["hash"]["ok"]
        @profile_sites.each { |ps|
          ps.update_attributes({:syndicated => true, :updated_at => Time.now})
        }        
        properties.each{|x| x.destroy}     
      end
    }
  end
end
