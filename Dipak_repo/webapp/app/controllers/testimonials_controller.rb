class TestimonialsController < ApplicationController

  before_filter :partner_ac_required, :except => [:feed]
  before_filter :prepare_params, :only => [:create]
  before_filter :load_logo, :except => [:feed]
  before_filter :validate_secret, :only => [:feed]

  SITE_SECRETS = {
    "3a4a4a13f326353ae81f230a8702cc8e" => "phill",
    "1bc9fadb15b6a3cc5d779c49fcb2cdd9" => "roi", 
    "d8fb6b5e2e30041251cde0d7a7e4e8cc" => "torok"
  }

  def index
    @testimonial = Testimonial.new
    @testimonial_picture = TestimonialPicture.new
  end

  def feed
    @testimonials = Testimonial.find(:all, :conditions => ["tools_used LIKE (?)", "%#{SITE_SECRETS[params[:api_key]]}%"], :include => :testimonial_pictures)

    @title = case SITE_SECRETS[params[:api_key]]
             when "phill"
               "Phill Grove"
             when "roi"
               "Top One"
             when "torok"
               "Mark Torok"
             end
               
    respond_to do |format|
      format.html
      format.rss  { render :layout => false }
    end
  end

  def create
    if @testimonial.save
      if @pictures
        @pictures.each{|file|
          TestimonialPicture.create!(:uploaded_data => file, :testimonial_id => @testimonial.id) 
        }
      end

      if params['testimonial_seller'] == '1'
        testimonial = @testimonial.associate_testimonials.build(params['seller_testimonial'])
        testimonial.type = 'seller'
        testimonial.save
      end

      if params['testimonial_buyer'] == '1'
        testimonial = @testimonial.associate_testimonials.build(params['buyer_testimonial'])
        testimonial.type = 'buyer'
        testimonial.save
      end

      if params['testimonial_agent'] == '1'
        testimonial = @testimonial.associate_testimonials.build(params['closing_agent'])
        testimonial.type = 'closing_agent'
        testimonial.save
      end

      flash[:notice] = 'Testimonial was successfully created.'
      redirect_to :action => :index
    end
  end

  protected

  def prepare_params
    if params[:testimonial][:pictures]
      @pictures = params[:testimonial].delete('pictures')
    end
    @testimonial = Testimonial.new(params[:testimonial].merge({:partner_account_id => current_user.partner_account.id}))
    @testimonial.tools_used = params[:testimonial][:tools_used].join(',') if params[:testimonial][:tools_used]
    @testimonial.strategies = params[:testimonial][:strategies].join(',') if params[:testimonial][:strategies]
    @testimonial.picture_types = params[:testimonial][:picture_types].join(',') if params[:testimonial][:picture_types]
    @testimonial.market_release = false unless params[:testimonial][:market_release]
  end

  def partner_ac_required
    if current_user == :false
      session[:wp_url] = nil
      render :template => "/sessions/new", :layout => "login_ui"
      return false
    end

    return true if current_user.partner_account
    render :file => "#{RAILS_ROOT}/public/404.html"
    return false
  end
  
  def load_logo
    if File.exists?("#{RAILS_ROOT}/public/images/#{current_user.partner_account.permalink}_logo.jpg")
      @partner_logo = "/images/#{current_user.partner_account.permalink}_logo.jpg"
    else
      @partner_logo = "/images/reiLogo.png"
    end
  end
  
  def validate_secret
    if SITE_SECRETS.has_key?(params[:api_key])    
      return true
    end
    render :file => "#{RAILS_ROOT}/public/404.html"
    return false
  end
end
