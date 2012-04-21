/**
 * Manages the New ProfileMessage screen
 */
NL.NewMessageFormController = Class.create();
NL.NewMessageFormController.prototype = {


    handleSubmit: function(event) {
        new Ajax.Request(this.remote_url, {method: 'post',asynchronous:true, evalScripts:true, onFailure:function(request){this.handleRequestFailure(request.responseText, request.status)}.bindAsEventListener(this), onComplete:function(request){this.handleLoaded()}.bindAsEventListener(this), onLoading:function(request){this.handleLoading()}.bindAsEventListener(this), onSuccess:function(request){this.handleRequestSuccess(request)}.bindAsEventListener(this),onException:function(request,e){this.handleRequestException(request,arguments[2]);}.bindAsEventListener(this), parameters:Form.serialize(this.form_element)});
        Event.stop(event);
    },

    handleRequestSuccess: function(request) {
        response_text = request.responseText;
        //alert(response_text);
        $('profile_message_form').update(response_text);
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

    handleCancelButtonClick: function(event) {
        $('dashboard_subcontent').hide();
        $('dashboard').show();
    },

    attachListenerToCancelButton: function() {
        cancel_buttons = $$('form input.cancel_button');
        for (var i = 0, length = cancel_buttons.length; i < length; i++) {
              Event.observe(cancel_buttons[i], 'mousedown', function(event) {
                                this.handleCancelButtonClick(event);
                                Event.stop(event);
                            }.bindAsEventListener(this));
        }
    },

    //
    // -- Constructor
    //

    initialize: function(remote_url, form_element, tab_controller) {
        this.remote_url = remote_url;
        this.form_element = form_element;
        Event.observe(form_element, 'submit', function(event) {
                          this.handleSubmit(event);
                      }.bindAsEventListener(this));
        this.attachListenerToCancelButton();
        // set the form to the default send_to based on the tab selected
        if(tab_controller) {
            this.tab_controller = tab_controller;
            current_tab = tab_controller.model.tab;
            current_filter = current_tab.getAttribute("result_filter");
            checkboxes = form_element.getElementsBySelector("input[type=checkbox]");
            for (var i = 0, length = checkboxes.length; i < checkboxes.length; i++) {
                checkbox = checkboxes[i];
                if(checkbox.id == "profile_message_form[send_to][]" && checkbox.value == current_filter) {
                    checkbox.checked = true;
                }
            }
        }
    }
}
