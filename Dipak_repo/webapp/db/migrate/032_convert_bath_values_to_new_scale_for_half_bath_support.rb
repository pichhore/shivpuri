class ConvertBathValuesToNewScaleForHalfBathSupport < ActiveRecord::Migration
  def self.up
    # in reverse order, convert existing bath profile_fields to the new scale
    # as indicated in profile_display_helper#property_bathrooms_display_hash
    # (1,3,5,7,9 are the whole numbers 1, 2, 3, 4, 5)
    rows = ProfileField.update_all("profile_fields.value = '11'","profile_fields.key = 'baths' and profile_fields.value = '6'")
    puts "#{rows} updated for baths 6->11"

    rows = ProfileField.update_all("profile_fields.value = '9'","profile_fields.key = 'baths' and profile_fields.value = '5'")
    puts "#{rows} updated for baths 5->9"

    rows = ProfileField.update_all("profile_fields.value = '7'","profile_fields.key = 'baths' and profile_fields.value = '4'")
    puts "#{rows} updated for baths 4->7"

    rows = ProfileField.update_all("profile_fields.value = '5'","profile_fields.key = 'baths' and profile_fields.value = '3'")
    puts "#{rows} updated for baths 3->5"

    rows = ProfileField.update_all("profile_fields.value = '3'","profile_fields.key = 'baths' and profile_fields.value = '2'")
    puts "#{rows} updated for baths 2->3"

    # 1 is the same

    puts "Refreshing profile criteria"
    ProfileFieldEngineIndex.refresh_indices
  end

  def self.down
    # not gonna reverse this unless I have to
  end
end
