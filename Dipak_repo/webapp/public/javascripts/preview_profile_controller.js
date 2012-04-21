/**
 * Manages the preview_buyer and preview_owner pages from the homepage
 */
NL.PreviewProfileController = Class.create();
NL.PreviewProfileController.prototype = {

    goToSignup: function() {
        //alert("OK");
        document.location = this.join_url;
    },

    handleContactButtonClick: function(event) {
        message = "You may contact a member of the community for free, without risking your email address. All communication occurs through our system, safely and privately. \n\nJoin now (it's free)?";

        answer = confirm(message);
        if(answer) {
            this.goToSignup();
        } else {

        }
    },

    handleFavIconClick: function(event) {
        message = "Favorites allow buyers to track their properties easily.\n\nNote: the property that you are attempting to add is matched by zip code only. Upon profile creation, it is possible that this property may not appear as a match on your 'My dwellgo' page. See faq entry 'Why is my favorite not showing up' for more details\n\nJoin now (it's free)?";

        answer = confirm(message);
        if(answer) {
            this.goToSignup();
        } else {

        }
    },

    attachContactButtonListener: function(element) {
        Event.observe(element, 'mousedown', function(event) {
                          this.handleContactButtonClick(event);
                      }.bindAsEventListener(this));
        Event.observe(element, 'mouseover', function(event) {
                          Event.element(event).classNames().add("hover");
                      }.bindAsEventListener(this));
        Event.observe(element, 'mouseout', function(event) {
                          Event.element(event).classNames().remove("hover");
                      }.bindAsEventListener(this));
    },

    attachFavIconListener: function(element) {
        Event.observe(element, 'mousedown', function(event) {
                          this.handleFavIconClick(element);
                      }.bindAsEventListener(this));
        Event.observe(element, 'mouseover', function(event) {
                          Event.element(event).classNames().add("hover");
                          if(Event.element(event).hasClassName("unselected")) {
                              Event.element(event).src = "/images/favorite_star_selected.gif";
                          } else {
                              Event.element(event).src = "/images/favorite_star_unselected.gif";
                          }
                      }.bindAsEventListener(this));
        Event.observe(element, 'mouseout', function(event) {
                          Event.element(event).classNames().remove("hover");
                          if(Event.element(event).hasClassName("unselected")) {
                              Event.element(event).src = "/images/favorite_star_unselected.gif";
                          } else {
                              Event.element(event).src = "/images/favorite_star_selected.gif";
                          }
                      }.bindAsEventListener(this));
    },

    initialize: function(join_url) {
        this.join_url = join_url;
        $$('div.icon_contact').each(function(item) { this.attachContactButtonListener(item); }.bindAsEventListener(this) );
        $$('div.profile.favicon').each(function(item) { this.attachFavIconListener(item); }.bindAsEventListener(this) );
    }

}