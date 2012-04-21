class UpdateZipCodesWithCorrectTerritories < ActiveRecord::Migration
  def self.up
    run_query("correct_territories.txt",[ "update zips set territory_id=", " where zip=" , ""] )
  end

  def self.down
    run_query("incorrect_territories.txt",[ "update zips set territory_id=", " where zip=" , ""] )
  end

  def self.run_query(filename, array = Array.new())
    file = File.new(File.dirname(__FILE__)+"/../"+filename, "r")
    file.readlines.each do |line|
      line_array = line.strip.split("\t")
      line_string = array[0]
      (array.length-1).times { |i| 
        line_string += line_array[i] 
        line_string += array[i+1] 
      }
      execute(line_string)
    end
  end
end
