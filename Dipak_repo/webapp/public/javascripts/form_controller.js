NL.FormController = Class.create();
NL.FormController.prototype = {

    attachValidator: function() {
        // attach the validation library to the form (from http://tetlaw.id.au/view/javascript/really-easy-field-validation)
        // (and set consistent behavior across the site)
        new Validation(this.form_element,{stopOnFirst:true});
    },

    initialize: function(form_element) {
        this.form_element = form_element;
        this.attachValidator();
    }
}
