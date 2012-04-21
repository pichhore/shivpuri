NL.ExpandCollapseController = Class.create();
NL.ExpandCollapseController.prototype = {

    handleHeadingClick: function() {
        if(this.heading_element.hasClassName("expanded")) {
            this.heading_element.className="collapsed";
            this.element_to_hide.hide();
        } else {
            this.heading_element.className="expanded";
            new Effect.Appear(this.element_to_hide);
        }
    },

    initialize: function(heading_element, element_to_hide) {
        this.heading_element = heading_element;
        this.element_to_hide = element_to_hide;
        Event.observe(this.heading_element, 'mousedown', function(event) {
                          this.handleHeadingClick();
                      }.bindAsEventListener(this));
        Event.observe(this.heading_element, 'mouseover', function(event) {
                          Event.element(event).addClassName('hover');
                      }.bindAsEventListener(this));
        Event.observe(this.heading_element, 'mouseout', function(event) {
                          Event.element(event).removeClassName('hover');
                      }.bindAsEventListener(this));
    }
}
