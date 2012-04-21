/**
 * Buyer/Owner Dashboard management
 */
NL.BuyerWebPageExpandProfileController = Class.create();
NL.BuyerWebPageExpandProfileController.prototype = {

     showLink: function(element) { 
        desc_full_details = element.getElementsByClassName('view_full_desc')[0];
        description_full_text_ele  =  element.getElementsByClassName('description_full')[0]; 
        var hhh = description_full_text_ele.getHeight() ;
//         if(hhh > 206)
          desc_full_details.style.display= "block";
      },

     hideLink: function(element) {
        desc_full_details = element.getElementsByClassName('view_full_desc')[0];
        desc_full_details.hide();
      },

  handleClickToShowFullDesc: function(element) {
            view_full_desc = element.getElementsByClassName('view_full_desc')[0];
            description_full_text= element.getElementsByClassName('description_full_text')[0];
            if(element.hasClassName('expanded')){
              $(element).classNames().remove("expanded");
              $(element).classNames().add("full_expanded");
              description_full_text.style.height = "auto";
              view_full_desc.update("View Full Details"); // View Short Details
            }else{
              $(element).classNames().remove("full_expanded");
              $(element).classNames().add("expanded");
             description_full_text.style.height = "81px";
              view_full_desc.update("View Full Details");
            }
      },

    handleClick: function(element) {
        el = $(element);
        desc_full = el.getElementsByClassName('description_full')[0];
        view_full_details = el.getElementsByClassName('view_full_desc')[0];
        if(view_full_details.getStyle('display') == "block") { 
           this.hideLink(element);
        } else {
           this.showLink(element);
        }
        if(desc_full.getStyle('display') == "none") {
            this.expandProfile(element);
            element.getElementsBySelector('img.collapsed_indicator').each(function(item) { item.src="/images/arrow-expanded.gif";  }.bindAsEventListener(this));
        } else {
            this.collapseProfile(element);
            element.getElementsBySelector('img.collapsed_indicator').each(function(item) { item.src="/images/arrow-collapsed.gif"; }.bindAsEventListener(this));
        }
    },

   expandProfile: function(element) {
        desc_full = element.getElementsByClassName('description_full')[0];
        desc_full.show();
        element.classNames().add("expanded");
        description_full_text= element.getElementsByClassName('description_full_text')[0];
        description_full_text.style.height = "80px";
        desc_short = element.getElementsByClassName('description_short')[0];
        if(desc_short) {
            desc_short.hide();
        }
    },

    collapseProfile: function(element) {
        desc_full = element.getElementsByClassName('description_full')[0];
        desc_full.hide();
        element.classNames().remove("expanded");
        desc_short = element.getElementsByClassName('description_short')[0];
        if(desc_short) {
            desc_short.show();
        }
    },

    attachProfileMatchesDetailLinkListeners: function() {
        $$('#profile_list div.profile').each(function(item) { this.attachListenersToMatchProfileDiv(item) }.bindAsEventListener(this));
    },

    attachListenersToMatchProfileDiv: function(element) {
        Event.observe(element.getElementsByClassName('desc_margin')[0], 'mousedown', function(event) {
                          this.handleClick(element);
                      }.bindAsEventListener(this));

        Event.observe(element.getElementsByClassName('view_full_desc')[0], 'mousedown', function(event) {
                          this.handleClickToShowFullDesc(element);
                      }.bindAsEventListener(this));
    },


    initialize: function() {
        // get the statically generated profiles attached to listeners
        this.attachProfileMatchesDetailLinkListeners();
    }
}

