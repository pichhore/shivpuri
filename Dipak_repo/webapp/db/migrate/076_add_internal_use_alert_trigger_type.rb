class AddInternalUseAlertTriggerType < ActiveRecord::Migration
  def self.up
    exists = AlertTriggerType.table_exists? rescue false
    if exists
      transaction do
        puts "Adding alert trigger types for testing"
        AlertTriggerType.create!({:name=>'Admin-only', :method_name=>'admin_only', :parameter_description=>'No extra parameters',
                                  :description=>'Will create an alert for users with admin rights.', 
                                 })
        AlertTriggerType.create!({:name=>'By Domain', :method_name=>'domain_matches', :parameter_description=>'The domain to match, not including the @',
                                  :description=>'Will create an alert for users with @domain in their e-mail address.'
                                 })
        AlertTriggerType.create!({:name=>'By Login', :method_name=>'login_matches', :parameter_description=>'A login (usually the e-mail address)',
                                  :description=>'Creates an alert for a specific login.'
                                 })
     end
    end
  end

  def self.down
  end
end
