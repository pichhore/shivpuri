/**
 * Handles Google Maps Streetview.  Currently just used on the Property Profile
 */
 

NL.StreetViewController = Class.create();
NL.StreetViewController.prototype = {
	
	timer : null,
	
    initialize: function(map) {
			this.map = map;
			this.streetviewClient = new GStreetviewClient();
	        this.streetviewClient.getNearestPanorama(map.getCenter(), this.handleCheckForStreetview.bindAsEventListener(this));
	        Event.observe(window, 'unload', this.handleStreetviewUnload.bindAsEventListener(this));
		},
	
	handleStreetviewUnload : function() {
		if (this.streetview) {
			this.streetview.remove();
			this.streetview = null;
		}
	},
	 
    handleError : function(errorCode) {
    	if (timer) {
    		clearTimeout(timer);
    		timer = null;
    	}
		this.streetview = null;
		this.close();
    	if (errorCode == 603) {
    		alert("The Adobe Flash player is required for this functionality.");
    	} else {
    		alert('Encountered an error while displaying Street View');
    	}
		this.handleStreetviewUnload;
    },
    
    /* Don't even show the button if we can't find a panorama for the lat/lng */
    handleCheckForStreetview : function(streetviewData) {
    	// Don't show the button for anything other than 200
		if (streetviewData.code == 200) {
			// The default point of view won't be pointing at the house.  Get a rough
			// approximation using the panorama lat/lng, which is always in the street,
			// and the house lat/lng, which is usually on the side of the street.
			this.calculateYaw(streetviewData.location.latlng, this.map.getCenter());
			$('streetview_button').show();	// the button they click to show the streetview
			Event.observe('streetview_button', 'click', this.handleStreetviewClick.bindAsEventListener(this));
		}
	},
	
	handleStreetviewClick : function() {
		this.loading();
		this.streetview = new GStreetviewPanorama($('streetview_contents'));
        GEvent.addListener(this.streetview, 'error', this.handleError.bindAsEventListener(this));
        var pov =  {yaw:this.bearing};
		Event.observe('streetview_close', 'click', this.close);
		this.streetview.setLocationAndPOV(map.getCenter(),pov);
		// Avoid showing the container until we have a chance to check the error
		timer = setTimeout(this.loaded.bindAsEventListener(this), 100);
	},

	/* Calculates the yaw (bearing) part of the point of view. */
	calculateYaw : function(pt1, pt2) {
		var dLon = pt2.lng() - pt1.lng();
		var y = Math.sin(dLon) * Math.cos(pt2.lat());
		var x = Math.cos(pt1.lat())*Math.sin(pt2.lat()) -
        Math.sin(pt1.lat())*Math.cos(pt2.lat())*Math.cos(dLon);
		this.bearing = this.toBearing(Math.atan2(y, x));
	},
	
	toDegrees : function(radians) {  // convert radians to degrees (signed)
	  return radians * 180 / Math.PI;
	},

	toBearing : function(angle) {  // convert radians to degrees (as bearing: 0...360)
	  return (this.toDegrees(angle)+360) % 360;
	},
	
	/* This uses a different lightbox popup because FireFox has problems with the
	 * transparency of the lightbox overlay when the Flash loads.  These methods
	 * were copied from lightbox_controller.js but point to a different set of
	 * containers.
	 */
	loading: function() {
        $$('div.loading').each(function(item) {
                                   item.show();
                               });
    },

    loaded: function() {
        $$('div.loading').each(function(item) {
                                   item.hide();
                               });
        $('overlay_Streetview').show();
        $('lightbox_Streetview').show();
    },

    close: function() {
        $$('div.loading').each(function(item) {
                           item.hide();
                       });
        $('overlay_Streetview').hide();
        $('lightbox_Streetview').hide();
    }
}