/**
 * Tracks clicks on an element, finds the URI attribute, and changes to that page
 */
NL.ClickToUriController = Class.create();
NL.ClickToUriController.prototype = {

    handleClick: function(event) {
        Event.stop(event);
        the_clicked_element = Event.element(event);
        if(the_clicked_element.getAttribute("uri") != null) {
            the_uri_element = the_clicked_element;
        } else {
            the_uri_element = the_clicked_element.up(this.class_name_that_stores_uri); /* e.g. '.message' */
        }

        if(the_uri_element) {
            the_uri = the_uri_element.getAttribute("uri");
            if(the_uri) {
                document.location = the_uri;
            }
        }
    },

    attachListeners: function(elements) {
        for (var i = 0, length = elements.length; i < length; i++) {
            Event.observe(elements[i], 'mousedown', function(event) {
                              this.handleClick(event);
                          }.bindAsEventListener(this));
        }
    },

    initialize: function(class_name_that_stores_uri) {
        this.class_name_that_stores_uri = class_name_that_stores_uri;
    }

}