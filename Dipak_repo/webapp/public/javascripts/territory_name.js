  function full_territory(this_id)
  {
      var children = this_id.getElementsByTagName('div');
            for (var i=0; i < children.length; i++) { 
                $(children[i]).removeClassName("span_display_none");
                $(children[i]).addClassName("span_display_block");
            }
  }
  function short_territory(this_id)
  {
      var children = this_id.getElementsByTagName('div');
            for (var i=0; i < children.length; i++) { 
                $(children[i]).removeClassName("span_display_block");
                $(children[i]).addClassName("span_display_none");
            }
   }