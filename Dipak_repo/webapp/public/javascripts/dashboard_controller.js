/**
 * Buyer/Owner Dashboard management
 */
NL.DashboardController = Class.create();
NL.DashboardController.prototype = {

    onTabChange: function(old_tab, new_tab) {
        the_sort = new_tab.getAttribute("default_sort");
        the_page_number = 1;
        this.updateTabContent(new_tab, the_page_number, the_sort);
    },

    onPageChange: function(to_page_number) {
        the_sort = this.sortable_controller.model.toUrlFormat();
        this.updateTabContent(null, to_page_number, the_sort);
    },

    onSortableChange: function(old_sortable, new_sortable, new_sortable_mode) {
        sort_field = new_sortable.getAttribute("sort");
        this.updateTabContent(null, 1, sort_field+","+new_sortable_mode);
    },

    updateTabContent: function(the_tab,the_page_number,the_sort,the_listing_type) {
        if(the_tab == null) {
            the_tab = this.tab_controller.model.tab;
        }
        tab_type = the_tab.getAttribute("result_filter");
        if(the_page_number == null) {
            the_page_number = 1;
        }
        if(the_sort == null) {
            the_sort = this.sortable_controller.model.toUrlFormat();
        }
        if(the_listing_type == null) {
        	the_listing_type = this.listing_type;
        } else {
        	this.listing_type = the_listing_type;
        }

        if(tab_type != "messages") {
            scroll(0,0);
            this.updateProfileMatchesTab(the_tab,the_page_number,the_sort,the_listing_type);
        } else {
            scroll(0,0);
            this.updateProfileMessagesTab(the_page_number, the_sort, the_listing_type);
        }
    },

    handleProfileMatchesUpdateRequest: function(request) {
        $('tab_content').update(request.responseText);
        $('message_center_legend').hide();
        $('primary_upper_left_box').show();
        this.pagination_controller.resetPagination();
        this.attachProfileMatchesDetailLinkListeners();
        this.attachListenersToSortHeadings();
        this.attachListenersToDashboardNav($('tab_content').getElementsBySelector('a.navigation_menu'));
        this.attachListenersToDashboardNav($('tab_content').getElementsBySelector('input.navigation_menu'));
    },

    handleProfileMessagesUpdateRequest: function(request) {
        $('tab_content').update(request.responseText);
        $('message_center_legend').show();
        $('primary_upper_left_box').hide();
        this.pagination_controller.resetPagination();
        //this.sortable_controller.initState($$('#profile_list div.headings div.sortable'));
        this.attachListenersToSortHeadings();
        this.attachProfileMessagesDetailLinkListeners();
    },

    handleProfileMessageViewClick: function(event) {
        the_element = Event.element(event);
        the_message_element = $(the_element).up('.message');
        if(the_message_element != null) {
            the_uri = the_message_element.getAttribute('uri');
            // new Ajax.Request(the_uri, {method: 'get',asynchronous:true, evalScripts:true, onFailure:function(request){this.handleRequestFailure(request.responseText, request.status)}.bindAsEventListener(this), onComplete:function(request){this.handleLoaded()}.bindAsEventListener(this), onLoading:function(request){this.handleLoading()}.bindAsEventListener(this), onSuccess:function(request){this.handleProfileMessageDetailViewRequest(request)}.bindAsEventListener(this),onException:function(request,e){this.handleRequestException(request,arguments[2]);}.bindAsEventListener(this) });
            document.location = the_uri;
        }
    },

    handleProfileMessageDetailViewRequest: function(request) {
        $('tab_content').update(request.responseText);
        this.view_message_controller.attachListeners($('tab_content'));
    },

    handleHover: function(element, hovering_flag) {
      if(hovering_flag) {
          $(element).classNames().add("hover");
      } else {
          $(element).classNames().remove("hover");
      }
    },

    handleClick: function(element) {
        el = $(element);
        desc_full = el.getElementsByClassName('description_full')[0];

        if(desc_full.getStyle('display') == "none") {
            this.expandProfile(element);
            element.getElementsBySelector('img.collapsed_indicator').each(function(item) { item.src="/images/arrow-expanded.gif";  }.bindAsEventListener(this));
        } else {
            this.collapseProfile(element);
            element.getElementsBySelector('img.collapsed_indicator').each(function(item) { item.src="/images/arrow-collapsed.gif"; }.bindAsEventListener(this));
        }
    },

    handleViewProfileClicked: function(event) {
        Event.stop(event);
        the_uri = Event.element(event).getAttribute("uri");
        if(the_uri) {
            document.location = the_uri;
        }
    },

    expandProfile: function(element) {
        desc_full = element.getElementsByClassName('description_full')[0];
        desc_full.show();
        element.classNames().add("expanded");
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
        Event.observe(element, 'mouseover', function(event) {
                          this.handleHover(element,true);
                      }.bindAsEventListener(this));
        Event.observe(element, 'mouseout', function(event) {
                          this.handleHover(element,false);
                      }.bindAsEventListener(this));
        Event.observe(element, 'mousedown', function(event) {
                          this.handleClick(element);
                      }.bindAsEventListener(this));
        fav_icons = element.getElementsBySelector('img.favorite_icon');
        for (var i = 0, length = fav_icons.length; i < length; i++) {
            fav_icon = fav_icons[i];
            this.fav_icon_controller.attachTo(fav_icon);
        }
        profile_details_links = element.getElementsBySelector('img.details_link');
        for (var i = 0, length = profile_details_links.length; i < length; i++) {
            profile_details_link = profile_details_links[i];
            Event.observe(profile_details_link, 'mousedown', function(event) {
                              this.handleViewProfileClicked(event);
                          }.bindAsEventListener(this));
            Event.observe(profile_details_link, 'mouseover', function(event) {
                              Event.element(event).addClassName('hover');
                          }.bindAsEventListener(this));
            Event.observe(profile_details_link, 'mouseout', function(event) {
                              Event.element(event).removeClassName('hover');
                          }.bindAsEventListener(this));
        }
        profile_details_links = element.getElementsBySelector('span.details_link');
        for (var i = 0, length = profile_details_links.length; i < length; i++) {
            profile_details_link = profile_details_links[i];
            Event.observe(profile_details_link, 'mousedown', function(event) {
                              this.handleViewProfileClicked(event);
                          }.bindAsEventListener(this));
            Event.observe(profile_details_link, 'mouseover', function(event) {
                              Event.element(event).addClassName('hover');
                          }.bindAsEventListener(this));
            Event.observe(profile_details_link, 'mouseout', function(event) {
                              Event.element(event).removeClassName('hover');
                          }.bindAsEventListener(this));
        }
    },

    attachListenersToSortHeadings: function() {
        this.sortable_controller.attachListeners($$('div.profile_summary div.headings div.sortable'));
        this.sortable_controller.attachListeners($$('div.message_summary div.headings div.sortable'));
    },

    attachProfileMessagesDetailLinkListeners: function() {
    	/* Removed link on the full box because there's one on goto and this was interfering with archiving
        $('tab_content').getElementsBySelector('div.message').each(function(item) {
              Event.observe(item, 'mousedown', function(event) {
                                this.handleProfileMessageViewClick(event);
                            }.bindAsEventListener(this));
              }.bindAsEventListener(this));
              */
        if ($('choose_message_filter')) {
          Event.observe('choose_message_filter', 'change', function(event) { this.updateProfileMessagesTab(1); }.bindAsEventListener(this));
        }
    },

    attachListenersToDashboardNav: function(elements) {
        this.dashboard_nav_controller.attachListeners(elements);
    },


    updateListingType: function(listing_type) {
    	  $$('.listing_type_cb').each(function(item) {
    	  	if (item.value != listing_type) {
    	  		item.checked = false;
    	  	}
    	  });
        tab = this.tab_controller.model.tab;
        result_filter = tab.getAttribute("result_filter");
        page_number = 1;
        sort = this.sortable_controller.model.toUrlFormat();
        this.listing_type = listing_type;
        var query_string = '?page_number='+page_number+'&result_filter='+result_filter+"&sort="+sort+"&listing_type="+listing_type;
        
        if(result_filter != "messages") {
            scroll(0,0);
            var full_url = window.location.pathname + query_string;
            this.handleLoading();
            window.location.href = full_url;            
        } else {
        	scroll(0,0);
          var full_url = window.location.pathname + query_string + '&result_filter=messages';
          this.handleLoading();
          window.location.href = full_url;          
        }
    },
    
    updateProfileMatchesTab: function(tab, page_number, sort, listing_type) {
        result_filter = tab.getAttribute("result_filter");
          var query_string ;
          var regexp = /\?from=buyer_leads$/;
          //alert(regexp.test(this.base_matches_list_url));
          if(regexp.test(this.base_matches_list_url))
              {query_string = '&page_number='+page_number+'&result_filter='+result_filter+"&sort="+sort+"&listing_type="+listing_type;}
          else
              {query_string = '?page_number='+page_number+'&result_filter='+result_filter+"&sort="+sort+"&listing_type="+listing_type;}
        var ajax_url = this.base_matches_list_url+query_string;
        new Ajax.Request(ajax_url, {method: 'get',asynchronous:true, evalScripts:true, onFailure:function(request){this.handleRequestFailure(request.responseText, request.status)}.bindAsEventListener(this), onComplete:function(request){this.handleLoaded()}.bindAsEventListener(this), onLoading:function(request){this.handleLoading()}.bindAsEventListener(this), onSuccess:function(request){this.handleProfileMatchesUpdateRequest(request)}.bindAsEventListener(this),onException:function(request,e){this.handleRequestException(request,arguments[2]);}.bindAsEventListener(this) });

    },

    updateProfileMessagesTab: function(page_number, the_sort, the_filter, the_listing_type) {
        if (the_sort == null) {
            the_sort = this.sortable_controller.model.toUrlFormat();
        }
        if (page_number == null) {
            page_number = this.pagination_controller.page_number;
        }
        if (the_filter == null && $('choose_message_filter')) {
        	the_filter = $('choose_message_filter').options[$('choose_message_filter').selectedIndex].value;
        } else {
        	the_filter = 'All';
        }
        if (the_listing_type == null) {
            the_listing_type = this.listing_type;
        }
        new Ajax.Request(this.base_message_list_url+"?page_number="+page_number+"&sort="+the_sort+"&message_filter="+the_filter
          +'&listing_type='+the_listing_type, 
          {method: 'get',asynchronous:true, evalScripts:true, 
          onFailure:function(request){this.handleRequestFailure(request.responseText, request.status)}.bindAsEventListener(this), 
          onComplete:function(request){this.handleLoaded()}.bindAsEventListener(this), 
          onLoading:function(request){this.handleLoading()}.bindAsEventListener(this), 
          onSuccess:function(request){this.handleProfileMessagesUpdateRequest(request)}.bindAsEventListener(this),
          onException:function(request,e){this.handleRequestException(request,arguments[2]);}.bindAsEventListener(this) });

    },

    handleRequestFailure: function(resultResponse, statusCode) {
        new NL.ErrorHandler().handleRequestFailure(resultResponse, statusCode);
        this.handleLoaded();
    },

    handleRequestException: function(request,e) {
        // Commenting temporarly to avoid alerts
        // new NL.ErrorHandler().handleRequestException(request,e);
        this.handleLoaded();
    },

    handleLoading: function() {
        $$('div.loading').each(function(item) {
                                   item.show();
                               });
    },

    handleLoaded: function() {
        $$('div.loading').each(function(item) {
                                   item.hide();
                               });
    },

    initialize: function(base_matches_list_url, base_message_list_url, remote_add_fav_url, contact_matches_url, tab_controller, sortable_controller, listing_type) {
        this.base_matches_list_url = base_matches_list_url;
        this.base_message_list_url = base_message_list_url;
        this.tab_controller        = tab_controller;
        this.fav_icon_controller   = new NL.FavoritesIconController(remote_add_fav_url);
        this.pagination_controller = new NL.PaginationController();
        this.dashboard_nav_controller = new NL.DashboardNavController(this);
        this.view_message_controller = new NL.ViewMessageController(this,null);
        this.pagination_controller.observe("page.change",function(to_page_number) {
                                       this.onPageChange(to_page_number);
                           }.bindAsEventListener(this));
        if(tab_controller) {
            this.tab_controller = tab_controller;
            //this.tab_controller.model.observe("tab.change",function(dummy_value, old_tab, new_tab) {
	    //                                     this.onTabChange(old_tab, new_tab);
	    //                                 }.bindAsEventListener(this));
	    this.tab_controller.model.observe("tab.change", this.onTabChange.bind(this));
        }
        if(sortable_controller) {
            this.sortable_controller = sortable_controller;
	    // this.sortable_controller.model.observe("sortable.change",
            //                                       function(dummy_value, old_sortable, new_sortable, new_sortable_mode) {
            //                                           this.onSortableChange(old_sortable, new_sortable, new_sortable_mode);
	    //                                        }.bindAsEventListener(this));
      this.sortable_controller.model.observe('sortable.change', this.onSortableChange.bind(this));
        }
        this.contact_matches_url   = contact_matches_url;
        this.listing_type = listing_type;

        // get the statically generated profiles attached to listeners
        this.attachProfileMatchesDetailLinkListeners();
        this.attachListenersToSortHeadings();
        this.attachListenersToDashboardNav($$('a.navigation_menu'));
        this.attachListenersToDashboardNav($$('input.navigation_menu'));
    }
}

