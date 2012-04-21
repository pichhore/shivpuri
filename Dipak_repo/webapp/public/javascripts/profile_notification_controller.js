NL.ProfileNotificationController = Class.create();
NL.ProfileNotificationController.prototype = {

    onTabChange: function(old_tab, new_tab) {
        uri = new_tab.getAttribute("uri");
        if(uri) {
            document.location = uri;
        }
    },

    initialize: function() {
        this.tab_controller = new NL.TabController(2, $$('div.tabset')[0]);
	//        this.tab_controller.model.observe("tab.change",function(dummy_value, old_tab, new_tab) {
        //                                      this.onTabChange(old_tab, new_tab);
	//                                   }.bindAsEventListener(this));
	this.tab_controller.model.observe("tab.change", this.onTabChange.bind(this));
    }
}