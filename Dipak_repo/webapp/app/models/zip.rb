class Zip < ActiveRecord::Base
  has_many :zctas
  belongs_to :territory

  def latlng
    lat.to_s + ',' + lng.to_s
  end

  def self.get_center_latlng(buyer_web_page)
    if buyer_web_page.map_location.blank?
      self.find(:all, 
                :conditions => { :territory_id => buyer_web_page.user_territory.territory_id }, 
                :select => "avg(lat) as lat, avg(lng) as lng"
                )
    else
      self.find(:all, :conditions => {:zip => buyer_web_page.map_location})
    end
  end
  
  def self.get_zips_for_state(state_id)
    zip_array = self.find(:all, 
                          :conditions => { :state => State.find_by_id(state_id).state_code}
                          )
    zip_array.collect{|z| z.zip}
  end
  
  def self.get_zips_for_territory(territory_id)
    zip_array = self.find(:all, 
                          :conditions => { :territory_id => territory_id}
                          )
    zip_array.collect{|z| z.zip}
  end

  def self.get_zips_for_state_on_preview(state_id,country_id)
    country = (!country_id.blank? and country_id == "CA") ? "ca" : "us"
    zip_array = self.find(:all, 
                          :conditions => {:country => country , :state => State.find_by_id(state_id).state_code}
                          )
    zip_array.collect{|z| z.zip}
  end
  
  def self.get_zips_for_territory_on_preview(territory_id,country_id)
    country = (!country_id.blank? and country_id == "CA") ? "ca" : "us"
    zip_array = self.find(:all, 
                          :conditions => {:country => country , :territory_id => territory_id}
                          )
    zip_array.collect{|z| z.zip}
  end
  
  def self.latlng(profile)
    zip = Zip.find(:first, :conditions => {
                     :zip => ProfileFieldEngineIndex.find(:first, :conditions => {:profile_id => profile.id}).zip_code})
                
    return zip.lat.to_s+","+zip.lng.to_s unless zip.nil?
  end

  def same_territory_zips
    self.territory.zips.map{|x| x.zip}
  end
end
