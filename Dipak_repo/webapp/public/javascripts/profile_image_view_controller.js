/**
 * Buyer/Owner Profile View Page
 */
NL.ProfileImageViewController = Class.create();
NL.ProfileImageViewController.prototype = {
	
    dataSource : {},
	
    handleThumbnailClicked: function(event) {
        img_url = Event.element(event).getAttribute("uri") || this.fullsize_element.src;
        this.fullsize_element.src = img_url;
    },

    attachThumbnailListener: function(fullsize_element) {
        Event.observe(fullsize_element, 'mousedown', function(event) {
                          this.handleThumbnailClicked(event);
                      }.bindAsEventListener(this));
        Event.observe(fullsize_element, 'mouseover', function(event) {
                          Event.element(event).addClassName('hover');
                      }.bindAsEventListener(this));
        Event.observe(fullsize_element, 'mouseout', function(event) {
                          Event.element(event).removeClassName('hover');
                      }.bindAsEventListener(this));
    },

    initialize: function(fullsize_element, micro_thumbnail_elements) {
        this.fullsize_element = fullsize_element;
        this.micro_thumbnail_elements = micro_thumbnail_elements;
        this.micro_thumbnail_elements.each(function(item) {
          if (item.getAttribute("uri").indexOf("property-170.jpg") < 0) {
	          this.attachThumbnailListener(item);
	          // The YUI lightbox technique uses this dataSource array
    	      this.dataSource[item.id] = { url: item.getAttribute("uri").replace(/_profile([\.$])/, "$1"), title: ''};
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