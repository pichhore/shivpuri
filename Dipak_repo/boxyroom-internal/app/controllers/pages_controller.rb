class PagesController < ApplicationController
  def faq
     if current_user
      @selected_tab = "none"
      render :layout=>"new/application"
   else
      render :layout=>"new/external_user"
    end
  end

  def home
    render :layout => "new/login"
  end

  def coming_soon
    render :layout => "coming_soon"
  end

  def privacy_policy
   if current_user
      @selected_tab = "none"
      render :layout=>"new/application"
   else
      render :layout=>"new/external_user"
    end
  end

  def terms_of_use
   if current_user
      @selected_tab = "none"
      render :layout=>"new/application"
   else
      render :layout=>"new/external_user"
    end
  end

  def how_it_works
    if current_user
      @selected_tab = "none"
      render :layout=>"new/application"
   else
      render :layout=>"new/external_user"
    end
  end

  def contact_us
     if current_user
      @selected_tab = "none"
      render :layout=>"new/application"
   else
      render :layout=>"new/external_user"
    end
  end


  def learn
    if current_user
      @selected_tab = "none"
      render :layout=>"new/application"
   else
      render :layout=>"new/external_user"
    end
  end

#   def learn_more
#     if current_user
#       @selected_tab = "none"
#       render :layout=>"new/application"
#    else
#       render :layout=>"new/external_user"
#     end
#   end

  def safe
    if current_user
      @selected_tab = "none"
      render :layout=>"new/application"
   else
      render :layout=>"new/external_user"
    end
  end

end
