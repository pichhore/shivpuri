require 'net/http'

class GeocodeExistingProfiles < ActiveRecord::Migration
  def self.up
    say_with_time "geocoding profiles" do
      Profile.find( :all ).each do |profile|
        profile.latlng
      end
    end
  end

  def self.down
  end
end
