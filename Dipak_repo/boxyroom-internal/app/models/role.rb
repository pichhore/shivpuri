class Role < ActiveRecord::Base
  belongs_to :user

  def role_admin!
   self.update_attribute(:title, 'admin');
  end

  def role_user!
   self.update_attribute(:title, 'user');
  end

end
