/**
 * Manages the public profile page, including sending a message to the profile
 */
NL.PublicProfileController = Class.create();
NL.PublicProfileController.prototype = {

    handleNewMessageButtonClick: function(event) {
        new Ajax.Request(this.remote_new_message_url, {method: 'get',asynchronous:true, evalScripts:true, onFailure:function(request){this.handleRequestFailure(request.responseText, request.status)}.bindAsEventListener(this), onComplete:function(request){this.handleLoaded()}.bindAsEventListener(this), onLoading:function(request){this.handleLoading()}.bindAsEventListener(this), onSuccess:function(request){this.handleRequestSuccess(request)}.bindAsEventListener(this),onException:function(request,e){this.handleRequestException(request,arguments[2]);}.bindAsEventListener(this)});
    },

    handleRequestSuccess: function(request) {
        response_text = request.responseText;
        $('dashboard_subcontent').update(response_text);
        $('dashboard_subcontent').show();
        $('dashboard').hide();
    },

    handleRequestFailure: function(resultResponse, statusCode) {
        new NL.ErrorHandler().handleRequestFailure(resultResponse, statusCode);
        this.handleLoaded();
    },

    handleRequestException: function(request,e) {
        new NL.ErrorHandler().handleRequestException(request,e);
        this.handleLoaded();
    },

    handleLoading: function(jsonResults) {
        $$('div.loading').each(function(item) {
                                   item.show();
                               });
    },

    handleLoaded: function(jsonResults) {
        $$('div.loading').each(function(item) {
                                   item.hide();
                               });
    },

    //
    // -- Constructor
    //

    initialize: function(remote_new_message_url, target_id) {
        this.remote_new_message_url = remote_new_message_url;
        // Target id is passed in on the dashboard page so we can create a new controller for each property
        if (! target_id) {
          contact_buttons = $$('div.icon_contact');
        } else {
          contact_buttons = $$('#' + target_id + '.icon_contact_list');
        }
        for (var i = 0, length = contact_buttons.length; i < length; i++) {
              Event.observe(contact_buttons[i], 'mousedown', function(event) {
                                this.handleNewMessageButtonClick(event);
                                Event.stop(event);
                            }.bindAsEventListener(this));
              Event.observe(contact_buttons[i], 'mouseover', function(event) {
                          Event.element(event).classNames().add("hover");
                            }.bindAsEventListener(this));
              Event.observe(contact_buttons[i], 'mouseout', function(event) {
                          Event.element(event).classNames().remove("hover");
                            }.bindAsEventListener(this));
        }
        $$('div.icon_contact_disabled').each(function(item) {
              Event.observe(item, 'mousedown', function(event) {
                                alert("Community members viewing your profile can send you a private message without your email address.");
                                Event.stop(event);
                            }.bindAsEventListener(this));
                               });
    }
}
