/**
 * Observes mouseover and mouseout events, attaching or remove the class 'hover' to the elements
 * passed in the array of the constructor
 */
NL.HoverController = Class.create();
NL.HoverController.prototype = {

    //
    // -- Constructor
    //

    initialize: function(element_array) {
        for (var i = 0, length = element_array.length; i < length; i++) {
            Event.observe(element_array[i], 'mouseover', function(event) {
                              $(this).classNames().add("hover");
                          }.bindAsEventListener(element_array[i]));
            Event.observe(element_array[i], 'mouseout', function(event) {
                              $(this).classNames().remove("hover");
                          }.bindAsEventListener(element_array[i]));
        }

    }
}

