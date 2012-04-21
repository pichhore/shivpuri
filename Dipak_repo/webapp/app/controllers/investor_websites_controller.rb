class InvestorWebsitesController < ReiWebsitesController

  before_filter :login_required
  layout "application"
  before_filter :set_site_type
  uses_yui_editor(:only=>[:new,:set_up,:step2,:edit,:update,:create])

  def index
    @my_websites = current_user.my_websites.find(:all, :conditions => [ " site_type in (?)",[ @website_type.capitalize + "Website", @website_type.capitalize + "WebPage"]] ) || []
  end

  def show
   redirect_to :action=>:set_up
  end

  def new
   redirect_to :action=>:set_up
  end

  def edit
    @investor_website = InvestorWebsite.find_by_id(params[:id])
    render :file => "#{RAILS_ROOT}/public/404.html" and return if @investor_website.blank?
    @domain_name = @investor_website.my_website.domain_name
    @investor_website_image = InvestorWebsiteImage.find_investor_website_image(@investor_website.id)
  end

  def set_up
    @investor_website = InvestorWebsite.new
    render :action=>:new
  end

  def create
    @investor_website = current_user.build_investor_website(params[:investor_website])
    my_website = @investor_website.build_my_website(:domain_name => params[:domain_name],:user_id=>current_user.id)
    @investor_website_links = InvestorWebsiteLinks.new(params[:investor_website_links])
    if @investor_website.save
      my_website.save
      @investor_website_links.investor_website_id = @investor_website.id
      @investor_website_links.save!
      enter_domain_name if (params[:investor_website][:domain_type] == MyWebsiteForm::DOMAIN_TYPE[:having] || params[:investor_website][:domain_type] == MyWebsiteForm::DOMAIN_TYPE[:buying])
      unless params[:investor_website_image].nil? || params[:investor_website_image][:uploaded_data].blank?
        render :action=>:edit and return if upload_investor_website_image(false)
      end
      render :action=>:edit and return if @flag_invalid_image
      flash[:notice] = 'Investor Website was successfully created.'
      redirect_to :action=>:index 
    else
      # Hack for IE .. multiple YUI editor are causing the POST request to be fired multiple times , so hacking for now .
      if flash[:notice] == 'Investor Website was successfully created.'
        flash[:notice] = 'Investor Website was successfully created.'
        return redirect_to :action=>:index
      end
      render :action=>:step2
      end
  end

  def update
   @investor_website = InvestorWebsite.find_by_id(params[:id])
     render :file => "#{RAILS_ROOT}/public/404.html" and return if @investor_website.blank?
     if @investor_website.domain_type ==  MyWebsiteForm::DOMAIN_TYPE[:having]
       params[:investor_website][:permalink_text] = params[:investor_website][:my_website_attributes][:domain_name].to_s.delete"./"
     end

    if params[:investor_website_link]
      logger.info"=====its here ==="
      @investor_website_links = InvestorWebsiteLinks.find_by_id(params[:investor_website_link][:id])
      @investor_website_links.update_attributes!(params[:investor_website_links])
    else
      logger.info"========investor website link record creator======"
      @investor_website_links = InvestorWebsiteLinks.new(params[:investor_website_links])
      @investor_website_links.investor_website_id = @investor_website.id
      @investor_website_links.save!
    end
     if @investor_website.update_attributes(params[:investor_website])
      unless params[:investor_website_image].nil? || params[:investor_website_image][:uploaded_data].blank?
        render :action=>:edit and return if upload_investor_website_image(false)
      end
      render :action=>:edit and return if @flag_invalid_image
      flash[:notice] = 'InvestorWebsite was successfully updated.'
      enter_domain_name if (@investor_website.domain_type == MyWebsiteForm::DOMAIN_TYPE[:having] || @investor_website.domain_type == MyWebsiteForm::DOMAIN_TYPE[:buying])
      redirect_to :action=>:index
     else
       @domain_name = params[:domain_name]
       @link_to_paste = params[:link_to_paste]
       render :action=>:edit
     end
  end

  def destroy
    @investor_website = InvestorWebsite.find_by_id(params[:id])
    render :file => "#{RAILS_ROOT}/public/404.html" and return if @investor_website.blank?
    domain_type = @investor_website.domain_type
    @investor_website.destroy
    enter_domain_name if (domain_type == MyWebsiteForm::DOMAIN_TYPE[:having] || domain_type == MyWebsiteForm::DOMAIN_TYPE[:buying])
    flash[:notice]= "Website deleted successfully."
    redirect_to :action=>:index
  end

 #Investor Website Setup process

  def step1
    render :file => "#{RAILS_ROOT}/public/404.html" and return if !current_user.investor_website.blank?
    @my_website_form = MyWebsiteForm.new
  end

  def step2
    @my_website_form = MyWebsiteForm.new
    @my_website_form.from_hash(params[:my_website_form])
    if @my_website_form.valid?
       if params[:my_website_form][:type] == MyWebsite::WEB_SITE_TYPE[:investor]
         @investor_website = InvestorWebsite.new
         set_investor_website_fields
       end
        # In future will add the buyer web site and need to check for that also.
    else
       render :action=>:step1
    end
  end

  def set_investor_website_fields
    if params[:my_website_form][:domain] == MyWebsiteForm::DOMAIN_TYPE[:reim]
      @investor_website.permalink_text = params[:my_website_form][:reim_domain_permalink1]
      @domain_name = params[:my_website_form][:reim_domain_name]
    elsif params[:my_website_form][:domain] == MyWebsiteForm::DOMAIN_TYPE[:having]
      @investor_website.permalink_text = params[:my_website_form][:having_domain_name].to_s.delete"./"
      @domain_name = params[:my_website_form][:having_domain_name]
      #Need to add the check for buying domains
    end
      @investor_website.header = InvestorWebsite::HEADER_TEXT
      @investor_website.home_page_text = InvestorWebsite::HOME_PAGE_TEXT1
  end

  def upload_investor_website_image(retrun_flag = true)
    @investor_website_image = InvestorWebsiteImage.new(params[:investor_website_image])
    @investor_website_image.investor_website_id = @investor_website.id
    if @investor_website_image.valid?
      investor_website_image = InvestorWebsiteImage.find(:all, :conditions=>[" investor_website_id = ? ",@investor_website.id])
      if investor_website_image.size > 0
        old_investor_website_image = InvestorWebsiteImage.find(investor_website_image[0].id)
        old_investor_website_image.destroy
      end
      @investor_website_image.save!
      flash.now[:notice] = "Image upload successfully."
      return retrun_flag
    else
      @investor_website_image = InvestorWebsiteImage.find_investor_website_image(@investor_website.id)
      flash.now[:notice] = "Invalid image format. Please check that the image is one of the support types and , it is under 3MB in size."
      @flag_invalid_image = true
      return false
    end
  end

private

  def set_site_type
    @website_type = 'investor'
  end
end