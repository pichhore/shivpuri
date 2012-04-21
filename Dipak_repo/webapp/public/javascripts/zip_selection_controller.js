/**
 * Controller/Model that stores the current list of zip code(s) selected by the user
 *
 * Events:
 *
 *  zipcodes.change - notifies observers when the zip code(s) has been changed
 *
 */
NL.ZipSelectionController = Class.create();
NL.ZipSelectionController.prototype = {
    zipcodes: null,

    change_zipcodes: function(new_zipcodes) {
        this.notify("zipcodes.change", this.zipcodes, new_zipcodes);
        this.zipcodes = new_zipcodes;
    },


    initialize: function(zipcodes) {
        this.zipcodes = zipcodes;
    }

}
// give the class event notification support
Object.Event.extend(NL.ZipSelectionController.prototype);
