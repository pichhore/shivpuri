class AddMoreFieldsToStudentProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :school, :string
    add_column :profiles, :course, :string
  end

  def self.down
    remove_column :profiles, :school
    remove_column :profiles, :course
  end
end
