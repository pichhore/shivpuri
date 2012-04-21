/**
 * Manages user clicks on a favorites icon to add/remove from their profile favorites list
 */
NL.FavoritesIconController = Class.create();
NL.FavoritesIconController.prototype = {

    handleFavoriteIconClick: function(event) {
        Event.stop(event); // don't let it trickle to any other components
        if(this.profile_id != null && this.profile_id == this.target_profile_id) {
            alert("Community members may add your profile as a favorite.");
            return;
        }
        the_fav_icon = Event.element(event);
        target_profile_id = the_fav_icon.getAttribute("profile_id");
        is_near = the_fav_icon.getAttribute("is_near");
        remote_remove_fav_url = this.remote_add_fav_url+"/"+target_profile_id;
        if(the_fav_icon.hasClassName("selected")) {
            new Ajax.Request(remote_remove_fav_url, {method: 'post',asynchronous:true, evalScripts:true, onFailure:function(request){this.handleRequestFailure(request.responseText, request.status)}.bindAsEventListener(this), onComplete:function(request){this.handleLoaded()}.bindAsEventListener(this), onLoading:function(request){this.handleLoading()}.bindAsEventListener(this), onSuccess:function(request){this.handleRemoveFavoriteResponse(request)}.bindAsEventListener(this),onException:function(request,e){this.handleRequestException(request,arguments[2]);}.bindAsEventListener(this), parameters: {"_method": "delete"} });
        } else {
            new Ajax.Request(this.remote_add_fav_url, {method: 'post',asynchronous:true, evalScripts:true, onFailure:function(request){this.handleRequestFailure(request.responseText, request.status)}.bindAsEventListener(this), onComplete:function(request){this.handleLoaded()}.bindAsEventListener(this), onLoading:function(request){this.handleLoading()}.bindAsEventListener(this), onSuccess:function(request){this.handleAddFavoriteResponse(request)}.bindAsEventListener(this),onException:function(request,e){this.handleRequestException(request,arguments[2]);}.bindAsEventListener(this), parameters: {"target_profile_id": target_profile_id, "is_near": is_near } });

        }

    },

    attachTo: function(fav_icon) {
        Event.observe(fav_icon, 'mousedown', function(event) {
                          this.handleFavoriteIconClick(event);
                      }.bindAsEventListener(this));
        Event.observe(fav_icon, 'mouseover', function(event) {
                          Event.element(event).classNames().add("hover");
                          if(Event.element(event).hasClassName("unselected")) {
                              Event.element(event).src = "/images/favorite_star_selected.gif";
                          } else {
                              Event.element(event).src = "/images/favorite_star_unselected.gif";
                          }
                      }.bindAsEventListener(this));
        Event.observe(fav_icon, 'mouseout', function(event) {
                          Event.element(event).classNames().remove("hover");
                          if(Event.element(event).hasClassName("unselected")) {
                              Event.element(event).src = "/images/favorite_star_unselected.gif";
                          } else {
                              Event.element(event).src = "/images/favorite_star_selected.gif";
                          }
                      }.bindAsEventListener(this));
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
        $$('div.loading').each(function(item) {
                                   item.show();
                               });
    },

    handleLoaded: function() {
        $$('div.loading').each(function(item) {
                                   item.hide();
                               });
    },

    handleAddFavoriteResponse: function(request) {
        $('scratch').update(request.responseText);
    },

    handleRemoveFavoriteResponse: function(request) {
        $('scratch').update(request.responseText);
    },

    initialize: function(remote_add_fav_url, profile_id, target_profile_id, is_near) {
        this.remote_add_fav_url = remote_add_fav_url;
        this.profile_id = profile_id;
        this.target_profile_id = target_profile_id;
        this.is_near = is_near;
    }
}
