require 'fastercsv'

class BouncedEmails
  
  def self.populate
    i = 0
    FasterCSV.foreach('Sendgridbounces.csv') do |row|
      if BouncedEmail.find_by_email(row[0]).nil?
        i += 1
        bounce = BouncedEmail.new
        bounce.email =  row[0]
        bounce.reason = row[3]
        bounce.save
      end
    end
    puts "loaded ----> #{i}"
  end
end
