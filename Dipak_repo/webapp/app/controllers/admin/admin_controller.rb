class Admin::AdminController < ApplicationController
  require 'fastercsv'

  layout "admin"
  before_filter :login_required
  before_filter :admin_required

  protected

  def admin_required
    return true if current_user.admin?
    render :text=>"Access denied", :status=>401
    return false
  end

end
