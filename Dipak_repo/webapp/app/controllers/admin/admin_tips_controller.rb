class Admin::AdminTipsController < Admin::AdminController
  active_scaffold :tip do |config|
    list.columns = [:target_page, :tip_text]
    list.sorting = {:target_page => 'ASC'}
    config.columns = [:tip_text, :target_page]
    columns[:target_page].description = "VALID VALUES: my_dwellgo, owner_dashboard, buyer_dashboard, show_owner, show_buyer"
    #config.actions.exclude :create, :delete
  end
end

