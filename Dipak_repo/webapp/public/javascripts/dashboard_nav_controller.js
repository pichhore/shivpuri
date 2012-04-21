/**
 * Observes mouse click events for the Dashboard navigation menu
 */
NL.DashboardNavController = Class.create();
NL.DashboardNavController.prototype = {

    handleMenuClick: function(event) {
        the_link = Event.element(event);
        the_remote_url = the_link.getAttribute("remote_link");
        the_link_type = the_link.getAttribute("link_type");
        this.requestNewDashboardContent(the_link_type, the_remote_url);
        Event.stop(event);
    },

    requestNewDashboardContent: function(the_link_type, the_remote_url) {
        if(the_link_type == "dashboard") {
            // hide subcontent
            //new Effect.Fade($('dashboard_subcontent'), { queue: 'end'});
            $('dashboard_subcontent').hide();
            // show dashboard
            //new Effect.Appear($('dashboard'), { queue: 'end'});
            $('dashboard').show();
            // TODO: update matches on dashboard based on any potential profile changes?!
        } else {
            new Ajax.Request(the_remote_url, {method: 'get',asynchronous:true, evalScripts:true, onFailure:function(request){this.handleRequestFailure(request.responseText, request.status)}.bindAsEventListener(this), onComplete:function(request){this.handleLoaded()}.bindAsEventListener(this), onLoading:function(request){this.handleLoading()}.bindAsEventListener(this), onSuccess:function(request){this.handleRequestSuccess(request)}.bindAsEventListener(this),onException:function(request,e){this.handleRequestException(request,arguments[2]);}.bindAsEventListener(this)});
        }
    },

    handleRequestSuccess: function(request) {
        // this method is invoked only if a non-dashboard link has been requested using AJAX
        response_text = request.responseText;
        the_dashboard = $('dashboard');
        the_dashboard_subcontent = $('dashboard_subcontent');
        if(the_dashboard_subcontent.visible) {
            //new Effect.Fade(the_dashboard_subcontent);
            the_dashboard_subcontent.hide();
        }
        $('dashboard_subcontent').update(response_text);
        if(the_dashboard_subcontent.visible) {
            //new Effect.Fade(the_dashboard_subcontent);
            the_dashboard_subcontent.hide();
        }
        if(the_dashboard.visible) {
            //new Effect.Fade(the_dashboard, { queue: 'end'});
            the_dashboard.hide();
        }
        //new Effect.Appear(the_dashboard_subcontent, { queue: 'end'});
        the_dashboard_subcontent.show();
        this.attachCancelButtonListeners();
    },


    handleCancelButtonClick: function() {
        the_dashboard = $('dashboard');
        the_dashboard_subcontent = $('dashboard_subcontent');
        //new Effect.Fade(the_dashboard_subcontent, { queue: 'end'});
        //new Effect.Appear(the_dashboard, { queue: 'end'});
        the_dashboard_subcontent.hide();
        the_dashboard.show();
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

    attachListeners: function(navigation_link_elements) {
        for (var i = 0, length = navigation_link_elements.length; i < length; i++) {
            navigation_link_element = navigation_link_elements[i];
            Event.observe(navigation_link_element, 'click', function(event) {
                              this.handleMenuClick(event);
                          }.bindAsEventListener(this));
        }

    },

    attachCancelButtonListeners: function() {
        $('dashboard_subcontent').getElementsBySelector('input.cancel_button').each(function(item) {
              Event.observe(item, 'mousedown', function(event) {
                                this.handleCancelButtonClick(event);
                                Event.stop(event);
                            }.bindAsEventListener(this));
              }.bindAsEventListener(this));
    },

    //
    // -- Constructor
    //

    initialize: function(dashboard_controller) {
        this.dashboard_controller = dashboard_controller;
    }
}
