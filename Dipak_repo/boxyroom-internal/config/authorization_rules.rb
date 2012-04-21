authorization do
  role :admin do
    includes :user

    has_permission_on :admin_properties, :to => [:index, :administrate, :refund, :property_verification]
    has_permission_on :admin_users, :to => [:index, :show, :reinstate, :suspend, :role_user, :role_admin]
    has_permission_on :admin_transactions, :to => [:index, :show, :close, :widthraw_done]
    has_permission_on :properties, :to => [:show]# allow admins to view a property no matter what status
  end

  role :user do
    includes :guest

    # properties
        has_permission_on :properties, :to =>[ :show,:like_properties]
#     has_permission_on :properties, :to => :show do
#       if_attribute :owner => is {user} # allow owners to preview their property
#     end

    has_permission_on :my_properties, :to => [:make]

    has_permission_on :my_properties, :to => [:show, :manage, :destroy, :resubmit, :relist, :receive_payment, :property_doc, :create_property_doc, :delete_property_doc, :picture_destroy, :payment_transfer_notification] do

      if_attribute :owner => is {user}
    end

    has_permission_on :my_applications, :to => [:show, :administrate] do
      if_attribute :property => {:owner => is {user}}
    end

    # applications

    has_permission_on :my_tenant_applications, :to => :make

    has_permission_on :my_tenant_applications, :to => [:show, :destroy, :resend, :pay, :manage, :write_review, :create_review, :make_payment,:payment_notification_detail, :my_applications ] do
      if_attribute :user => is {user}
    end

    # accounts

    has_permission_on :my_accounts, :to => [:show, :manage, :my_account,:more_applications,:my_dashboard, :my_properties, :my_profile, :delete_user_pic, :photos_property, :delete_image, :delete_previous_image, :upload_property_docs, :delete_prop_doc, :delete_previous_doc]

    # messages

    has_permission_on :my_messages, :to => [:index, :show, :make, :update]
  end
     
  role :guest do
    has_permission_on :properties, :to => [:index,:like_properties]
    has_permission_on :properties, :to => :show do
      if_attribute :status => "listed" # only show listed properties
    end

    has_permission_on :users, :to => :make
    has_permission_on :users, :to => :show do
      if_attribute :active => true, :suspended => false
    end

    has_permission_on :authorization_rules, :to => :read
  end

end

privileges do
  privilege :administrate do
    includes :approve, :reject
  end

  privilege :make do
    includes :new, :create
  end

  privilege :manage do
    includes :edit, :update
  end
end
