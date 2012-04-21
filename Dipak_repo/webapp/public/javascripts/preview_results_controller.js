/**
 * Manages the homepage preview results page (aka "lens")
 */
NL.PreviewResultsController = Class.create();
NL.PreviewResultsController.prototype = {

    onSortableChange: function(old_sortable, new_sortable, new_sortable_mode) {
        sort_field = new_sortable.getAttribute("sort");
        this.updateProfileMatches(sort_field+","+new_sortable_mode);
    },

    onZipCodesChange: function(old_zipcodes, new_zipcodes) {
        $$('input.zipcodes').each(function(item) {
                 item.value = new_zipcodes;
        }.bindAsEventListener(this));

        $$('div.zipcodes').each(function(item) {
                 item.update(new_zipcodes);
        }.bindAsEventListener(this));

        $$('span.zipcodes').each(function(item) {
                 item.update(new_zipcodes);
        }.bindAsEventListener(this));
    },

    handlePropertyTypeButtonClick: function(event) {
        selected_element = Event.element(event);
        new_property_type = selected_element.getAttribute("property_type");
        $$('div.property_type_selectors div.property_type_button').each(function(item) {
                 item.removeClassName("selected");
        }.bindAsEventListener(this));
        selected_element.addClassName("selected");
        this.property_type = new_property_type;
        this.page_number = 1;
        if ($('query_string')) {
          this.updateSearchResults();
        } else {
          this.updateProfileMatches();
        }
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
        profile_details_links = element.getElementsBySelector('img.details_link');
        for (var i = 0, length = profile_details_links.length; i < length; i++) {
            profile_details_link = profile_details_links[i];
            Event.observe(profile_details_link, 'mousedown', function(event) {
                              this.handleViewProfileClicked(event);
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

    attachListenersToButton: function(element) {
        Event.observe(element, 'mousedown', function(event) {
                          this.handlePropertyTypeButtonClick(event);
                      }.bindAsEventListener(this));
        Event.observe(element, 'mouseover', function(event) {
                          this.handleHover(element,true);
                      }.bindAsEventListener(this));
        Event.observe(element, 'mouseout', function(event) {
                          this.handleHover(element,false);
                      }.bindAsEventListener(this));
    },

    attachListenersToSortHeadings: function() {
        this.sortable_controller.attachListeners($$('div.profile_summary div.headings div.sortable'));
    },

    updateProfileMatches: function(new_sort_mode) {
        sort = new_sort_mode;
        if(sort == null) {
            sort = this.sortable_controller.model.toUrlFormat();
        }
        // scroll to the top of the page
	if (this.base_matches_list_url.match(/\?/)) {
        new Ajax.Request(this.base_matches_list_url+'&zip_code='+this.zip_selection_controller.zipcodes+'&page_number='+this.page_number+'&property_type='+this.property_type+"&sort="+sort,
			 {method: 'get',asynchronous:true, evalScripts:true, onFailure:function(request){this.handleRequestFailure(request.responseText, request.status)}.bindAsEventListener(this), onComplete:function(request){this.handleLoaded()}.bindAsEventListener(this), onLoading:function(request){this.handleLoading()}.bindAsEventListener(this), onSuccess:function(request){this.handleRequestSuccess(request); scroll(0,0);}.bindAsEventListener(this),onException:function(request,e){this.handleRequestException(request,arguments[2]);}.bindAsEventListener(this) }); }
	else {
        new Ajax.Request(this.base_matches_list_url+'?zip_code='+this.zip_selection_controller.zipcodes+'&page_number='+this.page_number+'&property_type='+this.property_type+"&sort="+sort,
			 {method: 'get',asynchronous:true, evalScripts:true, onFailure:function(request){this.handleRequestFailure(request.responseText, request.status)}.bindAsEventListener(this), onComplete:function(request){this.handleLoaded()}.bindAsEventListener(this), onLoading:function(request){this.handleLoading()}.bindAsEventListener(this), onSuccess:function(request){this.handleRequestSuccess(request); scroll(0,0);}.bindAsEventListener(this),onException:function(request,e){this.handleRequestException(request,arguments[2]);}.bindAsEventListener(this) });}
    },

    updateSearchResults: function() {
    	  scroll(0,0)
    	  var url = this.base_search_controller_url+'?page_number='+this.page_number+'&q='+$F('query_string')+'&property_type='+this.property_type+'&search_profile_type='+$F('search_profile_type');
        new Ajax.Request(url, 
         {method: 'get',asynchronous:true, evalScripts:true, onFailure:function(request){this.handleRequestFailure(request.responseText, request.status)}.bindAsEventListener(this), onComplete:function(request){this.handleLoaded()}.bindAsEventListener(this), onLoading:function(request){this.handleLoading()}.bindAsEventListener(this), onSuccess:function(request){this.handleRequestSuccess(request)}.bindAsEventListener(this),onException:function(request,e){this.handleRequestException(request,arguments[2]);}.bindAsEventListener(this) });
    },
    
    handleRequestSuccess: function(request) {
        response_text = request.responseText;
        $('tab_content').update(response_text);
        $$('#profile_list div.profile').each(function(item) { this.attachListenersToMatchProfileDiv(item) }.bindAsEventListener(this));
        this.attachListenersToSortHeadings();
        this.pagination_controller.resetPagination();
    },

    handleRequestFailure: function(resultResponse, statusCode) {
        new NL.ErrorHandler().handleRequestFailure(resultResponse, statusCode);
        this.handleLoaded();
    },

    handleRequestException: function(request,e) {
        new NL.ErrorHandler().handleRequestException(request,e);
        this.handleLoaded();
    },

    handleLoading: function() {
	// var offset = Element.cumulativeOffset($($$('div.buttonbar')[0]));
        $$('div.loading').each(function(item) {
            // item.setStyle({top: (offset[1])+'px', left: (offset[0])+'px'});
                                   item.show();
                               });

    },

    handleLoaded: function() {
        $$('div.loading').each(function(item) {
                                   item.hide();
                               });
    },

    onPageChange: function(to_page_number) {
        this.page_number = to_page_number;
        if ($('query_string')) {
        	this.updateSearchResults();
        } else {
          this.updateProfileMatches();
        }
    },

    initialize: function(base_matches_list_url, page_number, property_type, zip_selection_controller, base_search_controller_url) {
        this.base_matches_list_url = base_matches_list_url;
        this.base_search_controller_url = base_search_controller_url;
        this.page_number = page_number;
        this.property_type = property_type;
        this.pagination_controller = new NL.PaginationController();
        this.pagination_controller.observe("page.change",function(to_page_number) {
                                       this.onPageChange(to_page_number);
                           }.bindAsEventListener(this));
        this.sortable_controller = new NL.SortableController($$('#profile_list div.headings div.sortable'));
        //this.sortable_controller.model.observe("sortable.change",
	//                                      function(dummy_value, old_sortable, new_sortable, new_sortable_mode) {
	//                                          this.onSortableChange(old_sortable, new_sortable, new_sortable_mode);
	//                                      }.bindAsEventListener(this));
 this.sortable_controller.model.observe('sortable.change', this.onSortableChange.bind(this));

        this.zip_selection_controller = zip_selection_controller;
        this.zip_selection_controller.observe("zipcodes.change",
                                         function(dummy_value, old_zipcodes, new_zipcodes) {
                                             this.onZipCodesChange(old_zipcodes, new_zipcodes);
                                         }.bindAsEventListener(this));

        $$('div.property_type_selectors div.property_type_button').each(function(item) { this.attachListenersToButton(item); }.bindAsEventListener(this));
        $$('#profile_list div.profile').each(function(item) { this.attachListenersToMatchProfileDiv(item) }.bindAsEventListener(this));
    }

}