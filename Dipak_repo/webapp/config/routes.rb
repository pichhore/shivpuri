ActionController::Routing::Routes.draw do |map|

  map.resources :oauth_consumers,:member=>{:callback=>:get}


  map.connect "/pro", :controller => 'home', :action => 'pro'
  map.connect "/pro/webinar", :controller => 'home', :action => 'webinar'
  map.connect "/offer/sitesdoneforyou", :controller => 'home', :action => 'sitesdoneforyou'

  map.connect "/investor_buyer_web_page/:id/get_url/:squeeze_page", :controller => 'investor_buyer_web_page', :action => 'get_url'
  map.connect "/investor_buyer_web_page/:id/get_url/", :controller => 'investor_buyer_web_page', :action => 'get_url'
  map.connect "/testimonials/feed.:format", :controller => 'testimonials', :action => 'feed'
#   map.resources :states
  map.resources :testimonials
  map.connect "/s/:permalink_text/:id", :controller => 'amps_magnet', :action => 'sp_1', :requirements => {:id => /[\w\-]{36}/}
  map.connect "/m/:permalink_text/:id", :controller => 'amps_magnet', :action => 'sp_1', :requirements => {:id => /[\w\-]{36}/}

  map.resources :states, :collection => {:get_user_states => :get, :get_property_states => :get}
  map.resources :seller_websites, :collection=>{:set_up => :get, :seller_lead_management => :get, :add_new_seller => :get, :create_new_seller_profile => :post, :step1 => :get, :property => :get, :repairs => :get, :engagement_tab => :get, :financial_tab => :get, :add_seller_notes => :get, :seller_note_full_page_view => :get,:seller_website_example=>:get,:set_scratch_pad_note => :post, :get_sellers_for_suggestion => :get, :search_existing_seller => :post, :discard_scratch_pad_note_lightbox => :get, :delete_seller_note => :get, :auto_complete_for_profile_contract_my_buyer => :get }, :member => { :seller_lead_full_page_view => :get, :seller_lead_info => [:get, :post], :assign_existing_seller_lead => :post, :unassign_seller_lead => :get, :link_to_property_profile =>:get, :step1_for_generate_contract =>:get, :step2_for_generate_contract =>:get }


  map.resources :buyer_websites, :collection=>{:set_scratch_pad_note => :get, :discard_scratch_pad_note_lightbox => :get,:set_up => :get, :buyer_lead_management => :get, :add_new_buyer => :get, :create_new_buyer_profile => :post, :step1 => :get, :buyer_website_example=>:get, :update_domain => :post, :update_territory_block => :get, :update_preview_territory => :get, :delete_buyer_note => :get}, :member => { :buyer_lead_full_page_view => :get}

  map.resources :investor_websites, :collection => {:set_up => :get, :step1 => :get}


#   map.resources :seller_websites,:member=>{:seller_lead_full_page_view=>:get,:property=>:get,:repairs=>:get,:engagement_tab=>:get, :financial_tab=>:get},:collection=>{:set_up=>:get,:seller_lead_management=>:get,:step1=>:get}
  
  #map.resources :badges, :controller => '/admin/badges', :path_prefix => '/admin'
  if PartnerAccount.table_exists?
    PartnerAccount.all.each do |partner|
      map.connect "/#{partner.permalink}", :controller => 'testimonials', :action => 'index'
    end
  end

  map.resources :user_company_images
  map.resources :buyer_user_images
  map.namespace :admin do |admin|
    admin.resources :alert_definitions
    admin.resources :email_alert_definitions
    admin.resources :user_email_alert_definitions
    admin.resources :alert_trigger_types
    admin.resources :badges, :member  =>{:show_users_wrt_badges => :get}
    admin.resources :lah_product_purchased_by_users
    admin.resources :super_contract_integrations, :member => {:print_contract => :get}
  end
  map.resources :feeds do | feed |
    feed.resources :feed_item
  end
  map.resources :manage_subscriptions, :member => { :subscription_management => :get, :seller_responder_subscription_management => :get }
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # You can have the root of your site routed by hooking up ''
  # -- just remember to delete public/index.html.
  # map.connect '', :controller => "welcome"

  # Site homepage
  map.connect '', :controller => 'home'
  map.connect '/news-updates', :controller => 'home', :action => 'news_updates'
  #  map.connect '/lpo-1', :controller => 'home', :action => 'lpo_1'
  # Useful URLs
 map.investor_network '/account/investor_network',:controller => 'account', :action => 'investor_directory_page'
  map.login      '/login', :controller => 'sessions', :action => 'new'
  map.logout     '/logout', :controller => 'sessions', :action => 'destroy'
  map.contact_support_to_continue_services '/contact_support_to_continue_services', :controller => 'sessions', :action => 'shopping_cart_user_cancellation'
  map.tour       '/tour', :controller => 'home', :action => 'tour'
  map.properties '/properties', :controller => 'sitemap', :action => 'properties'
  map.property   '/property/:id', :controller => 'home', :action => 'property'
  map.community_message '/community_message', :controller=>'profile_messages', :action=>'create_community'
  map.send_mail '/send_mail', :controller => 'home', :action => 'send_mail'
  map.connect 'profiles/import', :controller => 'profiles', :action => 'import'
  map.connect '/web_services/add_user/:prodname', :controller => 'infusion',:action=>'index',:method=>:post
  map.connect '/shopping_cart_web_services/update_user', :controller => 'shopping_cart',:action=>'index',:method=>:post
  map.connect '/lah_shopping_cart_web_services/purchase_lah_product', :controller => 'lah_shopping_cart',:action=>'index',:method=>:post
  #Sendgrid Notification
  map.connect '/sendgrid/notification', :controller => 'smtp_notification',:action=>'index',:method=>:post
  map.connect '/account/property-syndication', :controller => 'account',:action=>'syndicate',:method=>:post
  map.connect '/profiles/manual-syndication/:id', :controller => 'profiles',:action=>'manual_syndication',:method=>:post
  # RESTful Resources

  map.resources :profiles, :collection => {:get_city_for_province => :get, :get_county_for_state => :get}, :member => { :edit_zipcodes => :get, :update_zipcodes => :post, :delete_confirm => :get, :mark_as_spam_for_profile => :post, :mark_as_spam_for_profile_inbox => :get, :edit_private_display_name => :get, :update_private_display_name => :post, :edit_notification => :get, :seller_lead_info => :get, :profile_contact => :get, :update_profile_contact => :put,:delete_deal => :delete } do |profiles|
    profiles.resources :profile_matches
    profiles.resources :profile_messages, :member => { :mark_as_spam => :get, :new_community => :get }
    profiles.resources :profile_favorites
    # view another profile under the context of this profile (for tracking and adding favorites)
    profiles.resources :profile_view
    # managing profile image uploads - requires acts_as_attachment
    profiles.resources :profile_images, :member => {:default_photo => [:post, :get]}
    # new message center conversation view
    profiles.resources :conversations
  end
  map.resources :public # public view of the profiles
  map.resources :users, :new => {:pro_offer => :get, :prothanks => :get, :thanks => :get, :buyer_created => :get, :owner_created => :get, :buyer_agent_created => :get, :seller_agent_created => :get}, :member => {:profiles => :get, :mark_as_spam => :get}
  map.resources :config
  map.resources :sessions
  map.resources :invitations, :new => {:thanks => :get}
  map.activate '/activate/:activation_code/profile/:profile_id', :controller => 'users', :action => 'activate'
  map.activate '/activate/:activation_code', :controller => 'users', :action => 'activate'
  map.update_password_from_forum '/update_password_from_forum', :controller => 'users', :action => 'update_password_from_forum', :method => :post
  map.user_activate '/user_activate/:activation_code', :controller => 'users', :action => "user_activate"

  map.permalink_profile_image '/images/profiles/:profile_id/profile-thumbnail' , :controller => 'images', :action => 'profile'
  map.permalink_user_company_image '/user_company_image/:user_id/profile-thumbnail' , :controller => 'images', :action => 'user_company_image'
  map.permalink_property_profile_image '/user_company_image/:profile_id/profile-thumbnail/:index' , :controller => 'images', :action => 'property_profile_image'

  map.resource :feedback, :controller => 'feedback', :new => {:thanks => :get}

  map.resources :ads

  map.activate '/admin', :controller => '/admin/start', :action => 'index'

  map.search '/search', :controller=> 'search', :action=>'new'

  #map.connect "/forsale/:id", :controller => 'home', :action => 'preview_owner'

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  # map.connect ':controller/service.wsdl', :action => 'wsdl'
  map.connect "/activate/", :controller => 'sessions', :action => 'new'

  begin
    Territory.find(:all).each do |territory|
      map.connect territory.reim_name + "/:id", :controller => 'investor_buyer_web_page', :action => 'investor_buyer_web_page'
      map.connect territory.reim_name + "/:id" + "/terms_of_use", :controller => 'investor_buyer_web_page', :action => 'terms_of_use'
      map.connect territory.reim_name + "/:business_name/:type/:address", :controller => 'investor_buyer_web_page', :action => 'property_view',:address=>nil
      map.connect territory.reim_name + "/:permalink/:type/:property_id/:full_page_view", :controller => 'investor_buyer_web_page', :action => 'property_full_view'
    end
  rescue
  end

  map.connect "/s/m/:permalink_text", :controller => 'amps_magnet', :action => 'sp_1'
  map.connect "/s/m/:permalink_text/:action", :controller => 'amps_magnet'

  map.connect "/s/:permalink_text", :controller => 'investor_seller_web_page', :action => 'seller_web_page',:permalink_text=>nil
  map.connect "/s/:permalink_text/:action", :controller => 'investor_seller_web_page'

  map.connect "/:property_id", :controller => 'profiles', :action => 'single_property_webpage', :property_id => /\d{6}/
  map.connect "/b/:permalink_text/:property_id", :controller => 'profiles', :action => 'single_property_webpage', :property_id => /\d{6}/
  map.connect "/b/:property_id", :controller => 'profiles', :action => 'single_property_webpage', :property_id => /\d{6}/

  map.connect "/i/:permalink_text", :controller => 'investor_web_page', :action => 'investor_web_page',:permalink_text=>nil
  map.connect "/i/:permalink_text/:action", :controller => 'investor_web_page'

  map.connect "/m/:permalink_text", :controller => 'amps_magnet', :action => 'sp_1'
  map.connect "/m/:permalink_text/:action", :controller => 'amps_magnet'
  map.connect "/b/:permalink_text/:property_id", :controller => 'profiles', :action => 'single_property_webpage', :property_id => /\d{6}/
  map.connect "/b/:property_id", :controller => 'profiles', :action => 'single_property_webpage', :property_id => /\d{6}/

  map.connect "/b/home/terms_of_use", :controller => 'home', :action => 'terms_of_use'
  map.connect "/b/:permalink_text/:id", :controller => 'home', :action => 'preview_owner', :id => /\d{6}/
  map.connect "/b/:id", :controller => 'home', :action => 'preview_owner', :id => /\d{6}/
  map.connect "/b/:permalink_text", :controller => 'investor_buyer_web_page', :action => 'investor_buyer_web_page_latest'
  map.connect "/b/:permalink_text/2", :controller => 'investor_buyer_web_page', :action => 'sequeeze_page'
  #map.connect "/b/forsale/:id", :controller => 'home', :action => 'preview_owner'
  #map.connect "/b/:permalink_text/forsale/:id", :controller => 'home', :action => 'preview_owner'
  #map.connect "/b/:id", :controller => 'home', :action => 'single_property_web_page'
  # map.connect "/b/:permalink_text/:id", :controller => 'home', :action => 'single_property_web_page'
  #map.connect "/b/:id", :controller => 'home', :action => 'preview_owner'
  #map.connect "/b/:permalink_text/:id", :controller => 'home', :action => 'preview_owner'
  map.connect "/b/:permalink_text/terms_of_use", :controller => 'investor_buyer_web_page', :action => 'terms_of_use_latest'
  map.connect "/b/investor_buyer_web_page/:action/:id", :controller => 'investor_buyer_web_page'
  map.connect "/b/profiles/multi_zip_select_latest", :controller => 'profiles', :action => 'multi_zip_select_latest'
  map.connect "/b/profiles/get_city_for_province", :controller => 'profiles', :action => 'get_city_for_province'
  map.connect "/b/:permalink_text/:type/:address", :controller => 'investor_buyer_web_page', :action => 'property_view_latest'
  map.connect "/b/:permalink_text/:type/:property_id/:full_page_view", :controller => 'investor_buyer_web_page', :action => 'property_full_view_latest'

  #map.connect "/b/login", :controller => 'sessions', :action => 'new'
  #map.connect "/b/account/profiles", :controller => 'account', :action => 'profiles'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'

end
