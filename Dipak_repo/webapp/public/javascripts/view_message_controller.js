/**
 * Manages the View Message page
 */
NL.ViewMessageController = Class.create();
NL.ViewMessageController.prototype = {

    handleCloseButtonClick: function(event) {
        this.dashboard_controller.updateProfileMessagesTab();
    },

    handleReplyButtonClick: function(event) {
        profile_id = Event.element(event).getAttribute("profile_id");
        the_url = this.base_message_list_url+"/new?profile_message_form[send_to][]=indiv&profile_message_form[indiv_profile_id]="+profile_id;
        if (this.reply_to_profile_message_id) {
            the_url += "&profile_message_form[reply_to_profile_message_id]="+this.reply_to_profile_message_id;
        }
        this.dashboard_controller.dashboard_nav_controller.requestNewDashboardContent("message",the_url);
    },

    attachListeners: function(starting_element) {
        starting_element.getElementsBySelector('input.close_button').each(function(item) {
              Event.observe(item, 'mousedown', function(event) {
                                this.handleCloseButtonClick(event);
                                Event.stop(event);
                            }.bindAsEventListener(this));
              }.bindAsEventListener(this));
        starting_element.getElementsBySelector('input.reply_button').each(function(item) {
              Event.observe(item, 'mousedown', function(event) {
                                this.handleReplyButtonClick(event);
                                Event.stop(event);
                            }.bindAsEventListener(this));
              }.bindAsEventListener(this));
    },

    //
    // -- Constructor
    //

    initialize: function(dashboard_controller, reply_to_profile_message_id) {
        this.dashboard_controller = dashboard_controller;
        this.base_message_list_url = dashboard_controller.base_message_list_url;
        this.reply_to_profile_message_id = reply_to_profile_message_id;
    }

}

/**
 * Replacement dashboard controller for non-dashboard screens that need similiar functionality
 */
NL.ViewMessageDashboardController = Class.create();
NL.ViewMessageDashboardController.prototype = {

    updateProfileMessagesTab: function(page_number) {
        document.location = this.dashboard_uri;
    },

    //
    // -- Constructor
    //

    initialize: function(base_message_list_url,dashboard_uri) {
        this.base_message_list_url = base_message_list_url;
        this.dashboard_uri = dashboard_uri;
        this.dashboard_nav_controller = new NL.DashboardNavController();
    }
}
