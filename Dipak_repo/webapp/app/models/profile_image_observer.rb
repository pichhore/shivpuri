class ProfileImageObserver < ActiveRecord::Observer
  def after_save(profile_image)
    # if this image doesn't have parent, then... (don't want to do this for thumbnails as well)
    if profile_image.parent_id.nil?
      # 1. load the profile related to the image
      profile = profile_image.profile
      # 2. determine if the number of profile images without a parent (root-level) is > 0
      count = profile.count_profile_images
      if count > 0
        # 3. if so, trigger an index update by saving the profile again (starts the observer)
        begin
          profile.skip_matches_update = true
          profile.save!
          profile.skip_matches_update = false 
        rescue
          profile.skip_matches_update = false
        end
      end
    end
  end

  def after_destroy(profile_image)
    # if this image doesn't have parent, then... (don't want to do this for thumbnails as well)
    if profile_image.parent_id.nil?
      # 1. load the profile related to the image
      profile = profile_image.profile
      # 2. determine if the number of profile images without a parent (root-level) is > 0
      count = profile.count_profile_images
      if count == 0
        # 3. if so, trigger an index update by saving the profile again (starts the observer)
        begin
          profile.skip_matches_update = true
          profile.save!
          profile.skip_matches_update = false 
        rescue
          profile.skip_matches_update = false
        end
      end
    end
  end

  def after_create(profile_image)
    # nothing to do
  end

  def after_update(profile_image)
    # nothing to do
  end
end
