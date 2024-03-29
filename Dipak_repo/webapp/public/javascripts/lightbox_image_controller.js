/**
 * Manages popup images
 */
 
NL.LightboxImageController = Class.create();
NL.LightboxImageController.prototype = {

    dataSource : {},
    
    initialize: function() {
        $$('img.details_link').each(function(item) {
          if (item.getAttribute("src").indexOf("property-60.jpg") < 0) {
            // The YUI lightbox technique uses this dataSource array
            this.dataSource[item.id] = { url: item.getAttribute("src").replace(/_medium([\.$])/, "$1"), title: ''};
          }
        }.bindAsEventListener(this));
        try {
          if (this.dataSource.length > 0 && typeof YAHOO!="undefined"||YAHOO) {
            // Set the hooks so that mouseover shows a larger view of the image
            var lightbox = new YAHOO.com.thecodecentral.Lightbox({
              imageBase:'/javascripts/yui/lightbox', 
              dataSource: this.dataSource
            });
          }
        } catch (ex) { // Must not be using YUI here
        }
    }
}