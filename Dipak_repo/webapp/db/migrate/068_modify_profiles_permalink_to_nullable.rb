class ModifyProfilesPermalinkToNullable < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE `profiles` MODIFY COLUMN `permalink` VARCHAR(255) NULL;"
  end

  def self.down
    execute "ALTER TABLE `profiles` MODIFY COLUMN `permalink` VARCHAR(255) NOT NULL;"
  end
end
