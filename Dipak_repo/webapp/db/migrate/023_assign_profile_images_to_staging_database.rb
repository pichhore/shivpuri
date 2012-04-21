class AssignProfileImagesToStagingDatabase < ActiveRecord::Migration
  def self.up
    if RAILS_ENV == "staging" or RAILS_ENV == "development"
      puts "Attaching example profile images to staging database"

      buyer_index = 0
      owner_index = 0
      Profile.find(:all).each do |profile|
        if profile.owner?
          owner_index += 1
          # assign profile pic
          if profile.property_type_single_family? or profile.property_type_multi_family? or profile.property_type_condo_townhome?
            profile_image = ProfileImage.new({ :id => "#{profile.id}_profile_image_1_full",
                                             :profile_id => profile.id,
                                             :content_type => "fixme",
                                             :filename => "/images/example_property_images/170x170/house_#{owner_index % 13}.jpg",
                                             :size => 0,
                                             :width => 170,
                                             :height => 170
                                             })
            profile_image.save!
            profile_image = ProfileImage.new({ :id => "#{profile.id}_profile_image_2_medium",
                                             :profile_id => profile.id,
                                             :content_type => "fixme",
                                             :filename => "/images/example_property_images/60x60/house_#{owner_index % 13}.jpg",
                                             :size => 0,
                                             :width => 60,
                                             :height => 60
                                             })
            profile_image.save!
            profile_image = ProfileImage.new({ :id => "#{profile.id}_profile_image_3_tiny",
                                             :profile_id => profile.id,
                                             :content_type => "fixme",
                                             :filename => "/images/example_property_images/60x60/house_#{owner_index % 13}.jpg",
                                             :size => 0,
                                             :width => 50,
                                             :height => 50
                                             })
            profile_image.save!
            # assign additional micro pics for public profile page
            profile_image = ProfileImage.new({ :id => "#{profile.id}_profile_bath_1_tiny",
                                             :profile_id => profile.id,
                                             :content_type => "fixme",
                                             :filename => "/images/example_property_images/60x60/bath_#{owner_index % 4}.jpg",
                                             :size => 0,
                                             :width => 50,
                                             :height => 50
                                             })
            profile_image.save!
            profile_image = ProfileImage.new({ :id => "#{profile.id}_profile_kitchen_1_tiny",
                                             :profile_id => profile.id,
                                             :content_type => "fixme",
                                             :filename => "/images/example_property_images/60x60/kitchen_#{owner_index % 12}.jpg",
                                             :size => 0,
                                             :width => 50,
                                             :height => 50
                                             })
            profile_image.save!
            profile_image = ProfileImage.new({ :id => "#{profile.id}_profile_room_1_tiny",
                                             :profile_id => profile.id,
                                             :content_type => "fixme",
                                             :filename => "/images/example_property_images/60x60/room_#{owner_index % 13}.jpg",
                                             :size => 0,
                                             :width => 50,
                                             :height => 50
                                             })
            profile_image.save!

          elsif profile.property_type_acreage?
            profile_image = ProfileImage.new({ :id => "#{profile.id}_profile_image_1_full",
                                             :profile_id => profile.id,
                                             :content_type => "fixme",
                                             :filename => "/images/example_property_images/170x170/land_#{owner_index % 9}.jpg",
                                             :size => 0,
                                             :width => 170,
                                             :height => 170
                                             })
            profile_image.save!
            profile_image = ProfileImage.new({ :id => "#{profile.id}_profile_image_2_medium",
                                             :profile_id => profile.id,
                                             :content_type => "fixme",
                                             :filename => "/images/example_property_images/60x60/land_#{owner_index % 9}.jpg",
                                             :size => 0,
                                             :width => 60,
                                             :height => 60
                                             })
            profile_image.save!
            profile_image = ProfileImage.new({ :id => "#{profile.id}_profile_image_3_tiny",
                                             :profile_id => profile.id,
                                             :content_type => "fixme",
                                             :filename => "/images/example_property_images/60x60/land_#{owner_index % 9}.jpg",
                                             :size => 0,
                                             :width => 50,
                                             :height => 50
                                             })
            profile_image.save!
            # NO assign additional micro pics for this type of owner

          elsif profile.property_type_vacant_lot?
            profile_image = ProfileImage.new({ :id => "#{profile.id}_profile_image_1_full",
                                             :profile_id => profile.id,
                                             :content_type => "fixme",
                                             :filename => "/images/example_property_images/170x170/lot_#{owner_index % 8}.jpg",
                                             :size => 0,
                                             :width => 170,
                                             :height => 170
                                             })
            profile_image.save!
            profile_image = ProfileImage.new({ :id => "#{profile.id}_profile_image_2_medium",
                                             :profile_id => profile.id,
                                             :content_type => "fixme",
                                             :filename => "/images/example_property_images/60x60/lot_#{owner_index % 8}.jpg",
                                             :size => 0,
                                             :width => 60,
                                             :height => 60
                                             })
            profile_image.save!
            profile_image = ProfileImage.new({ :id => "#{profile.id}_profile_image_3_tiny",
                                             :profile_id => profile.id,
                                             :content_type => "fixme",
                                             :filename => "/images/example_property_images/60x60/lot_#{owner_index % 8}.jpg",
                                             :size => 0,
                                             :width => 50,
                                             :height => 50
                                             })
            profile_image.save!
            # NO assign additional micro pics for this type of owner

          end

        elsif profile.buyer?
          buyer_index += 1
          # assign profile pic
          profile_image = ProfileImage.new({ :id => "#{profile.id}_profile_image_1_full",
                                           :profile_id => profile.id,
                                           :content_type => "fixme",
                                           :filename => "/images/example_buyer_images/buyer_#{buyer_index % 27}_170x170.jpg",
                                           :size => 0,
                                           :width => 170,
                                           :height => 170
                                           })
          profile_image.save!
          profile_image = ProfileImage.new({ :id => "#{profile.id}_profile_image_2_medium",
                                           :profile_id => profile.id,
                                           :content_type => "fixme",
                                           :filename => "/images/example_buyer_images/buyer_#{buyer_index % 27}_60x60.jpg",
                                           :size => 0,
                                           :width => 60,
                                           :height => 60
                                           })
          profile_image.save!
          profile_image = ProfileImage.new({ :id => "#{profile.id}_profile_image_3_tiny",
                                           :profile_id => profile.id,
                                           :content_type => "fixme",
                                           :filename => "/images/example_buyer_images/buyer_#{buyer_index % 27}_60x60.jpg",
                                           :size => 0,
                                           :width => 50,
                                           :height => 50
                                           })
          profile_image.save!
          # NO additional micro pics for public profile page for buyers
        end
      end
    end
  end

  def self.down
  end
end
