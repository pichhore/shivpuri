/**
 * Tracks details about the browser state for the ProfileList controller
 *
 * Events:
 *
 *  page.change - notifies observers when the page number has been changed
 *  mode.change - notifies observers when the display mode has been changed
 *  sort.change - notifies observers when the sort mode has been changed
 *
 *
 */
 
 /** Potentially unused code **/
NL.ProfileListModel = Class.create();
NL.ProfileListModel.prototype = {
    page_number: 1,
    total_pages: 1,
    remote_url: "",
    zip_code: "",
    result_filter: "",
    sort: "",

    change_page: function(to_page_number) {
        if(to_page_number <= this.total_pages && to_page_number > 0) {
            this.page_number = to_page_number;
            this.notify("page.change",to_page_number);
        }
    },

    change_result_filter: function(new_mode) {
        if(this.result_filter != new_result_filter) {
            this.result_filter = new_result_filter;
            this.notify("result_filter.change",new_result_filter);
        }
    },

    change_sort: function(new_sort) {
        if(this.sort != new_sort) {
            this.sort = new_sort;
            this.notify("sort.change",new_sort);
        }
    },

    has_more_pages: function() {
        return (this.page_number < this.total_pages);
    },

    on_first_page: function() {
        return (this.page_number == 1);
    },

    to_ajax_url: function() {
        return this.remote_url+'?page_number='+this.page_number+'&zip_code='+this.zip_code+'&result_filter='+this.result_filter+"&sort="+this.sort;
    },

    initialize: function (page_number, total_pages, remote_url, zip_code) {
        this.page_number = page_number;
        this.total_pages = total_pages;
        this.remote_url = remote_url;
        this.zip_code = zip_code;
    }
}
// give the class event notification support
Object.Event.extend(NL.ProfileListModel.prototype);


/**
 * Installs behavior on an element with the ID 'profiles_list'. Uses NL.ProfileListModel to track
 * state. Responds to both model changes and UI changes, and includes callbacks to the server using
 * AJAX (or AJAJ, as we use JSON).
 */
NL.ProfileListController = Class.create();
// define the core API
NL.ProfileListController.prototype = {

    //
    // -- Model Callbacks
    //

    onPageChange: function(new_page_number) {
        this.refresh_view();
    },

    onResultFilterChange: function(new_result_filter) {
        this.refresh_view();
    },

    onSortChange: function(new_sort) {
        this.refresh_view();
    },

    onTabChange: function(old_tab, new_tab) {
        new_result_filter = new_tab.getAttribute("result_filter");
        if(new_result_filter != "messages") {
            this.model.change_result_filter(new_result_filter);
        } else {
            new Ajax.Request(this.profile_messages_url, {method: 'get',asynchronous:true, evalScripts:true, onFailure:function(request){this.handleRequestFailure(request.responseText, request.status)}.bindAsEventListener(this), onComplete:function(request){this.handleResultListLoaded()}.bindAsEventListener(this), onLoading:function(request){this.handleResultListLoading()}.bindAsEventListener(this), onSuccess:function(request){this.handleMessageTabUpdate(request)}.bindAsEventListener(this),onException:function(request,e){this.handleRequestException(request,arguments[2]);}.bindAsEventListener(this)});
        }
    },

    onSortableChange: function(old_sortable, new_sortable, new_sortable_mode) {
        new_sortable_string = new_sortable.getAttribute("sort")+","+new_sortable_mode;
        this.model.change_sort(new_sortable_string);
    },

    //
    // -- UI Callbacks
    //

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
        } else {
            this.collapseProfile(element);
        }
    },

    handleRequestFailure: function(resultResponse, statusCode) {
        new NL.ErrorHandler().handleRequestFailure(resultResponse, statusCode);
        this.handleResultListLoaded();
    },

    handleRequestException: function(request,e) {
        new NL.ErrorHandler().handleRequestException(request,e);
        this.handleResultListLoaded();
    },

    handleResultListLoading: function(jsonResults) {
        $$('div.loading').each(function(item) {
                                   item.show();
                               });
    },

    handleResultListLoaded: function(jsonResults) {
        $$('div.loading').each(function(item) {
                                   item.hide();
                               });
    },

    handleUpdatedResultsList: function(responseText) {
        var jsonResults = eval(responseText);
        var the_profile_list = $('profile_list');
        var profile_divs = the_profile_list.getElementsBySelector("div.profile");
        for (var i = 0, length = profile_divs.length; i < length; i++) {
            if(profile_divs[i].id != "profile_template") {
                the_profile_list.removeChild(profile_divs[i]);
            }
        }
        var clone_from = $('profile_template') || profile_divs[0]; // use the template if on the dashboard, otherwise just use the first one (for preview pages)
        // make sure that if the cloned source element was showing the full description, hide it
        if(clone_from) {
                for (var i = 0, length = jsonResults.length; i < length; i++) {
                    var curr_json_result = jsonResults[i];
                    var new_profile_div = $(clone_from.cloneNode(true));
                    new_profile_div.id = "";
                    new_profile_div.setAttribute("profile_id",curr_json_result["id"]);
                    // update all elements that have a field_name attribute, using the value of the attribute as the key
                    // into the JSON structure
                    var field_list = new_profile_div.getElementsBySelector("span[field_name]");
                    if(field_list) {
                        for (var j = 0, length2 = field_list.length; j < length2; j++) {
                            var the_field = field_list[j];
                            var the_field_name = the_field.getAttribute("field_name");
                            var the_new_value = curr_json_result[the_field_name] || the_field.innerHTML;
                            the_field.update(the_new_value);
                        }
                        // set the favorites icon properly, based on the json field
                        var user_fav = curr_json_result["display_is_favorite"];
                        // get any img elements that have the class .image and .favorite_icon
                        var fav_icons = new_profile_div.getElementsBySelector("img.favorite_icon");
                        for (var k = 0, length3 = fav_icons.length; k < length3; k++) {
                            fav_icon = fav_icons[k];
                            // set the profile_id attribute
                            fav_icon.setAttribute("profile_id",curr_json_result["id"]);
                            if(user_fav == true) {
                                // add the class selected, remove unselected
                                fav_icon.removeClassName("unselected");
                                fav_icon.addClassName("selected");
                                // set the correct image path
                                fav_icon.src = '/images/favorite_star_selected.gif';
                            } else {
                                // add the class unselected, remove selected
                                fav_icon.removeClassName("selected");
                                fav_icon.addClassName("unselected");
                                // set the correct image path
                                fav_icon.src = '/images/favorite_star_unselected.gif';
                            }
                        }
                        // set the details uri properly, based on the json field
                        var details_uri = curr_json_result["display_details_uri"]
                        // get any img elements that have the class .image and .favorite_icon
                        var detail_icons = new_profile_div.getElementsBySelector("img.details_link");
                        for (var k = 0, length3 = detail_icons.length; k < length3; k++) {
                            detail_icon = detail_icons[k];
                            // set the profile_id attribute
                            detail_icon.setAttribute("uri",details_uri);
                        }
                        // attach listeners to the newly created element
                        this.attachListenersToProfileDiv(new_profile_div);
                        $(new_profile_div).hide();
                        this.collapseProfile(new_profile_div);
                        the_profile_list.appendChild(new_profile_div);
                        new Effect.Appear($(new_profile_div));
                    } else {
                        alert("No fields found");
                    }
                }
        }

        this.updatePageNav();

    },

    handlePrevPage: function() {
        this.model.change_page(this.model.page_number - 1);
        return false;
    },

    handleNextPage: function() {
        this.model.change_page(this.model.page_number + 1);
        return false;
    },

    handleViewProfileClicked: function(event) {
        Event.stop(event);
        the_uri = Event.element(event).getAttribute("uri");
        if(the_uri) {
            document.location = the_uri;
        }
    },

    handleMessageTabUpdate: function(request) {
        $('tab_content').update(request.responseText);
        // TODO: This method will be merged into this controller soon
        dashboard_controller.pagination_controller.resetPagination();
        dashboard_controller.attachProfileMessageDetailLinkListeners();

    },

    //
    // -- Helper methods
    //

    attachListenersToProfileDiv: function(element) {
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
        }
    },

    updatePageNav: function() {
        $('current_page_number').update(this.model.page_number);
        $('total_pages').update(this.model.total_pages);
        if(this.model.has_more_pages()) {
            $$('div.buttonbar a.next_page')[0].removeClassName('disabled');
        } else {
            $$('div.buttonbar a.next_page')[0].addClassName('disabled');
        }
        if (this.model.on_first_page()) {
            $$('div.buttonbar a.prev_page')[0].addClassName('disabled');
        } else {
            $$('div.buttonbar a.prev_page')[0].removeClassName('disabled');
        }
    },

    expandProfile: function(element) {
        desc_full = element.getElementsByClassName('description_full')[0];
        desc_full.show();
        element.classNames().add("expanded");
        feature_short = element.getElementsByClassName('feature_short')[0];
        feature_short.hide();
        feature_full = element.getElementsByClassName('feature_full')[0];
        feature_full.show();
        element.getElementsByClassName('description_short').each(function(item) {
                                   item.hide();
                               });
    },

    collapseProfile: function(element) {
        desc_full = element.getElementsByClassName('description_full')[0];
        desc_full.hide();
        element.classNames().remove("expanded");
        feature_short = element.getElementsByClassName('feature_short')[0];
        feature_short.show();
        feature_full = element.getElementsByClassName('feature_full')[0];
        feature_full.hide();
        element.getElementsByClassName('description_short').each(function(item) {
                                   item.show();
                               });
    },

    refresh_view: function() {
        new Ajax.Request(this.model.to_ajax_url(), {method: 'get',asynchronous:true, evalScripts:true, onFailure:function(request){this.handleRequestFailure(request.responseText, request.status)}.bindAsEventListener(this), onComplete:function(request){this.handleResultListLoaded()}.bindAsEventListener(this), onLoading:function(request){this.handleResultListLoading()}.bindAsEventListener(this), onSuccess:function(request){this.handleUpdatedResultsList(request.responseText)}.bindAsEventListener(this),onException:function(request,e){this.handleRequestException(request,arguments[2]);}.bindAsEventListener(this)});
    },

    //
    // -- Constructor
    //

    initialize: function(page_number, total_pages, remote_url, zip_code, tab_controller, sortable_controller, remote_add_fav_url, profile_messages_url) {
        this.model = new NL.ProfileListModel(page_number, total_pages, remote_url, zip_code);
        this.model.observe("page.change",function(to_page_number) {
                                       this.onPageChange(to_page_number);
                                   }.bindAsEventListener(this));
        this.model.observe("result_filter.change",function(new_result_filter) {
                                       this.onResultFilterChange(new_result_filter);
                                   }.bindAsEventListener(this));
        this.model.observe("sort.change",function(new_sort) {
                               this.onSortChange(new_sort);
                           }.bindAsEventListener(this));

        var profile_divs = $('profile_list').getElementsBySelector("div.profile");
        for (var i = 0, length = profile_divs.length; i < length; i++) {
            this.attachListenersToProfileDiv(profile_divs[i]);
        }
        this.updatePageNav();
        if(tab_controller) {
            this.tab_controller = tab_controller;
	    //            this.tab_controller.model.observe("tab.change",function(dummy_value, old_tab, new_tab) {
            //                                      this.onTabChange(old_tab, new_tab);
            //                                  }.bindAsEventListener(this));
        this.tab_controller.model.observe("tab.change", this.onTabChange.bind(this));
        }
        if(sortable_controller) {
            this.sortable_controller = sortable_controller;
	    // this.sortable_controller.model.observe("sortable.change",
            //                                       function(dummy_value, old_sortable, new_sortable, new_sortable_mode) {
            //                                           this.onSortableChange(old_sortable, new_sortable, new_sortable_mode);
	    //                                      }.bindAsEventListener(this));
      this.sortable_controller.model.observe('sortable.change', this.onSortableChange.bind(this));
        }
        this.profile_messages_url = profile_messages_url;
        this.remote_add_fav_url = remote_add_fav_url;
    }

 }
