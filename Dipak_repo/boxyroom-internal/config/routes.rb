ActionController::Routing::Routes.draw do |map|

  # restful resource(s)
  map.resources :users, :except => [:edit, :update]
  map.resources :activations
  map.resource :user_session
  map.resources :password_resets, :only => [:create, :edit, :update, :new]
  map.resources :properties ,   :member=>{:like_properties=>:get}
    #property.resources :applications
#   end
  
  # 'my' namespace routes
  map.namespace :my do |my|

    my.resource :account, :as => "dashboard",
      :except => [:new, :create, :destroy],:collection=>{:my_account=>:get, :more_applications => :get,:my_dashboard => :get, :my_properties => :get, :my_profile =>:get, :delete_user_pic => :get, :photos_property => :post, :delete_image => :get,  :delete_previous_image => :get, :upload_property_docs => :post, :delete_prop_doc => :get, :delete_previous_doc => :get}

    my.resources :applications,
      :controller => "tenant_applications",
      :path_names => {:destroy => "cancel"},
      :except => [:index],
      :member => {:resend => :put, :pay => :put, :write_review=> :get, :create_review=> :post,:make_payment=>:get ,:payment_notification_detail => :get},:collection => { :my_applications => :get}

    my.resources :properties,
      :path_names => {:destroy => "cancel"},
      :except => [:index],
     
#       :collection => {:photos_property => :post},
      :member => {:resubmit => :put, :relist => :put, :receive_payment => :get, :property_doc => :get, :create_property_doc => :post,   :delete_property_doc => :get, :picture_destroy => :get, :payment_transfer_notification => :get}do |property|

      property.resources :photos
      property.resources :applications,
        :except => [:index, :edit, :update, :destroy],
        :member => {:approve => :put, :reject => :put}
    end
       my.resources :messages
  end

  # 'admin' namespace routes
  map.namespace :admin do |admin|

    admin.resources :properties,
      :only => [:index],
      :member => {:approve => :put, :reject => :put, :refund => :put, :property_verification=> :get}
    
    admin.resources :users,
      :only => [:index, :show],
      :member => {:suspend => :delete, :reinstate => :put, :role_admin => :put , :role_user => :put}

    admin.resources :transactions,
      :only => [:index, :show],
      :member => {:close => :put, :widthraw_done => :put}
  end

  # named routes
  map.login     "/login", :controller => "user_sessions", :action => "new"
  map.logout    "/logout", :controller => "user_sessions", :action => "destroy"
  map.register  "/register", :controller => "users", :action => "new"
  map.activate  "/activate/:activation_code", :controller => 'activations', :action => 'new'
  map.password_resets     '/password_resets',       :controller => 'password_resets',       :action => 'create'

  # static pages
  map.with_options :controller => "pages" do |pages|
    pages.home "home", :action => "home"
    pages.faq "faq", :action => "faq"
    pages.coming_soon "coming_soon", :action => "coming_soon"
    pages.contact_us "contact_us", :action => "contact_us"
    pages.how_it_works "how_it_works", :action => "how_it_works"
    pages.privacy_policy "privacy_policy", :action => "privacy_policy"
    pages.terms_of_use "terms_of_use", :action => "terms_of_use"
    pages.learn_more "learn_more", :action => "learn"
#     pages.learn_more "learn/learn_more", :action => "learn_more"
    pages.safe "safe", :action => "safe"
  end

  # root route
  map.root :controller => "pages", :action => "home"

  # not confirmed if we want these routes
    map.connect ':controller/:action/:id'
    map.connect ':controller/:action/:id.:format'
end


