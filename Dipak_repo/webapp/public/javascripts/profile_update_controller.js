NL.ProfileUpdateController = Class.create();
NL.ProfileUpdateController.prototype = {

    onTabChange: function(old_tab, new_tab) {
        uri = new_tab.getAttribute("uri");
        if(uri) {
            document.location = uri;
        }
    },
     
   refreshOnlyChromeBack: function() {
            if($('refreshed')){
                  var check_back_refresh=$('refreshed');
                  if(check_back_refresh.value=="no")
                  check_back_refresh.value="yes";
                  else{
                        check_back_refresh.value="no";
                        location.reload();
                  }
            }
      },

    showOnlyFieldsForPropertyType: function() {

        if(       this.property_type == 'single_family') {

            $$('tr[include_sf="y"]').each(function(item) { new Effect.Appear(item); });
            $$('tr[include_sf="n"]').each(function(item) { item.hide(); });

        } else if(this.property_type == 'multi_family') {

            $$('tr[include_mf="y"]').each(function(item) { new Effect.Appear(item); });
            $$('tr[include_mf="n"]').each(function(item) { item.hide(); });

        } else if(this.property_type == 'condo_townhome') {

            $$('tr[include_ct="y"]').each(function(item) { new Effect.Appear(item); });
            $$('tr[include_ct="n"]').each(function(item) { item.hide(); });

        } else if(this.property_type == 'vacant_lot') {

            $$('tr[include_vl="y"]').each(function(item) { new Effect.Appear(item); });
            $$('tr[include_vl="n"]').each(function(item) { item.hide(); });

        } else if(this.property_type == 'acreage') {

            $$('tr[include_ac="y"]').each(function(item) { new Effect.Appear(item); });
            $$('tr[include_ac="n"]').each(function(item) { item.hide(); });

        } else if(this.property_type == 'other') {

            $$('tr[include_ot="y"]').each(function(item) { new Effect.Appear(item); });
            $$('tr[include_ot="n"]').each(function(item) { item.hide(); });

        } else if(this.property_type == '') {

            $$('tr[include_ac]').each(function(item) { item.hide(); });

        }

        if($('pool_label')) {
          if(this.property_type == 'condo_townhome') {
              $('pool_label').update("Community Pool:");
          } else {
              $('pool_label').update("Pool:");
          }
        }

        if($('property_tag_example_text')) {
            the_property_tag_example_text = "Trees, Pool, Granite Countertops"; // SF (default)
            if(this.property_type == 'multi_family')   { the_property_tag_example_text = "Covered Parking, Fully Leased, Separate Meters"; }
            if(this.property_type == 'condo_townhome') { the_property_tag_example_text = "Community Pool, Covered Parking, Remodeled"; }
            if(this.property_type == 'vacant_lot')     { the_property_tag_example_text = "Flat, Trees, Utilities On-site"; }
            if(this.property_type == 'acreage')        { the_property_tag_example_text = "Trees, Fenced, Pond, AG Exempt"; }
            if(this.property_type == 'other')          { the_property_tag_example_text = ""; }

            $('property_tag_example_text').update(the_property_tag_example_text);
        }
    },

    initialize: function(property_type) {
        this.refreshOnlyChromeBack();
        this.property_type = property_type;
        this.showOnlyFieldsForPropertyType();
        this.tab_controller = new NL.TabController(1, $$('div.tabset')[0]);
	//        this.tab_controller.model.observe("tab.change",function(dummy_value, old_tab, new_tab) {
	//                                     this.onTabChange(old_tab, new_tab);
	//                                 }.bindAsEventListener(this));
        this.tab_controller.model.observe("tab.change", this.onTabChange.bind(this));
    }
}