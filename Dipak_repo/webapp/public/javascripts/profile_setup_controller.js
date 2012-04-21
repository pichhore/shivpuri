NL.ProfileSetupController = Class.create();
NL.ProfileSetupController.prototype = {

    handlePropertyTypeSelected: function() {
        if(this.type_selector_element.value == 'single_family') {
	    $$('tr[include_sf="y"]').each(function(item) { new Effect.Appear(item); });
            $$('tr[include_sf="n"]').each(function(item) { item.hide(); });
            new Effect.Appear($('optional'));

        } else if(this.type_selector_element.value == 'multi_family') {

            $$('tr[include_mf="y"]').each(function(item) { new Effect.Appear(item); });
            $$('tr[include_mf="n"]').each(function(item) { item.hide(); });
            new Effect.Appear($('optional'));

        } else if(this.type_selector_element.value == 'condo_townhome') {

            $$('tr[include_ct="y"]').each(function(item) { new Effect.Appear(item); });
            $$('tr[include_ct="n"]').each(function(item) { item.hide(); });
            new Effect.Appear($('optional'));

        } else if(this.type_selector_element.value == 'vacant_lot') {

            $$('tr[include_vl="y"]').each(function(item) { new Effect.Appear(item); });
            $$('tr[include_vl="n"]').each(function(item) { item.hide(); });
            new Effect.Appear($('optional'));

        } else if(this.type_selector_element.value == 'acreage') {

            $$('tr[include_ac="y"]').each(function(item) { new Effect.Appear(item); });
            $$('tr[include_ac="n"]').each(function(item) { item.hide(); });
            new Effect.Appear($('optional'));

        } else if(this.type_selector_element.value == 'other') {

            $$('tr[include_ot="y"]').each(function(item) { new Effect.Appear(item); });
            $$('tr[include_ot="n"]').each(function(item) { item.hide(); });
            new Effect.Appear($('optional'));

        } else if(this.type_selector_element.value == '') {
            $$('tr[include_ac="y"]').each(function(item) { item.hide(); });
            $('optional').hide();
        }
        if(this.type_selector_element.value == 'condo_townhome') {
            $('pool_label').update("Community Pool:");
        } else {
            $('pool_label').update("Pool:");
        }

        if($('sqft_label')) {
          if(this.type_selector_element.value == 'multi_family') {
              $('sqft_label').update("Approx Sq Ft (all units):");
          } else {
              $('sqft_label').update("Approx Sq Ft:");
          }
        }

        if($('property_tag_example_text')) {
            the_property_tag_example_text = "Trees, Pool, Granite Countertops"; // SF (default)
            if(this.type_selector_element.value == 'multi_family')   { the_property_tag_example_text = "Covered Parking, Fully Leased, Separate Meters"; }
            if(this.type_selector_element.value == 'condo_townhome') { the_property_tag_example_text = "Community Pool, Covered Parking, Remodeled"; }
            if(this.type_selector_element.value == 'vacant_lot')     { the_property_tag_example_text = "Flat, Trees, Utilities On-site"; }
            if(this.type_selector_element.value == 'acreage')        { the_property_tag_example_text = "Trees, Fenced, Pond, AG Exempt"; }
            if(this.type_selector_element.value == 'other')          { the_property_tag_example_text = ""; }

            $('property_tag_example_text').update(the_property_tag_example_text);
        }

        if($('optional_heading')) {
            if(this.type_selector_element.value == 'other') {
                $('optional_heading').hide();
                optional_expand_collapse.handleHeadingClick();
            } else {
                $('optional_heading').show();
            }
        }

        if($('optional_owner_heading')) {
            if(this.type_selector_element.value == 'other') {
                $$('div.optional_content').each(function(item) { item.show();  });
                $('optional_owner_heading').removeClassName('collapsed');
                $('optional_owner_heading').addClassName('expanded');
            } else {
            }
        }


    },

    handlePublicProfileSelected: function() {
        // only for owner profile
        if($('property_address_label')) {
            $('property_address_label').addClassName("label_required");
            $('property_address_label').removeClassName("label");
        }
      if($('price_label')) {
            $('price_label').addClassName("label_required");
            $('price_label').removeClassName("label");
      }
      if($('min_mon_pay_label')) {
            $('min_mon_pay_label').addClassName("label_required");
            $('min_mon_pay_label').removeClassName("label");
      }
      if($('min_dow_pay_label')) {
            $('min_dow_pay_label').addClassName("label_required");
            $('min_dow_pay_label').removeClassName("label");
      }
      if($('arv_label')) {
            $('arv_label').addClassName("label_required");
            $('arv_label').removeClassName("label");
      }
      if($('vdb_label')) {
            $('vdb_label').addClassName("label_required");
            $('vdb_label').removeClassName("label");
      }
      if($('trn_label')) {
            $('trn_label').addClassName("label_required");
            $('trn_label').removeClassName("label");
      }
      if($('rcb_label')) {
            $('rcb_label').addClassName("label_required");
            $('rcb_label').removeClassName("label");
      }
    },

    handlePrivateProfileSelected: function() {
        // only for owner profile
        if($('property_address_label')) {
            $('property_address_label').removeClassName("label_required");
            $('property_address_label').addClassName("label");
        }
        if($('price_label')) {
            $('price_label').removeClassName("label_required");
            $('price_label').addClassName("label");
        }
        if($('min_mon_pay_label')) {
            $('min_mon_pay_label').removeClassName("label_required");
            $('min_mon_pay_label').addClassName("label");
        }
        if($('min_dow_pay_label')) {
            $('min_dow_pay_label').removeClassName("label_required");
            $('min_dow_pay_label').addClassName("label");
        }
        if($('arv_label')) {
            $('arv_label').removeClassName("label_required");
            $('arv_label').addClassName("label");
        }
        if($('vdb_label')) {
            $('vdb_label').removeClassName("label_required");
            $('vdb_label').addClassName("label");
        }
        if($('trn_label')) {
            $('trn_label').removeClassName("label_required");
            $('trn_label').addClassName("label");
        }
        if($('rcb_label')) {
            $('rcb_label').removeClassName("label_required");
            $('rcb_label').addClassName("label");
        }
    },

    initialize: function(type_selector_element, privacy_public_element, privacy_private_element) {
        this.type_selector_element = type_selector_element;
        this.privacy_public_element = privacy_public_element;
        this.privacy_private_element = privacy_private_element;
        // initial state setup
        this.handlePropertyTypeSelected();
        if(privacy_public_element && privacy_public_element.checked)
          this.handlePublicProfileSelected();
        if(privacy_private_element && privacy_private_element.checked)
          this.handlePrivateProfileSelected();
        // listen for UI events
        Event.observe(type_selector_element, 'change', function(event) {
                          this.handlePropertyTypeSelected();
                      }.bindAsEventListener(this));
        if(privacy_public_element && privacy_private_element) {
            Event.observe(privacy_public_element, 'click', function(event) {
                              this.handlePublicProfileSelected();
                          }.bindAsEventListener(this));
            Event.observe(privacy_private_element, 'click', function(event) {
                              this.handlePrivateProfileSelected();
                          }.bindAsEventListener(this));
        }

   }
}
