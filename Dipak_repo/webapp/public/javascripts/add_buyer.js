
 function get_property_value(y)
 {
  select_property_type = document.getElementById(y).value
  wholesale = document.getElementById("wholesale")
  owner_finance = document.getElementById("owner_finance")
  if(wholesale.checked == false && owner_finance.checked == false)
   {
    alert("Please select any investment type before proceding further")
    document.getElementById(y).selectedIndex = 0;
   }
   else
    {
      if(select_property_type != '' && wholesale.checked == true)
      {
       document.getElementById("maxpv").style.display = ''
       document.getElementById("arvr").style.display = ''
      }
     if(owner_finance.checked == true)
     {
      document.getElementById("maxmp").style.display = ''
      document.getElementById("maxdp").style.display = ''
     }
    }
 }

 function get_wholesale_owner_finance_value(){
  wholesale = document.getElementById("wholesale")
  owner_finance = document.getElementById("owner_finance")
  property_type_value = document.getElementById("fields_property_type").value
  if(!wholesale.checked && !owner_finance.checked)
  {
    alert("Please select any investment type before proceding further")
    document.getElementById("fields_property_type").selectedIndex = 0;
  }
  if(wholesale.checked)
  {
   if(property_type_value != '')
   {
    document.getElementById("maxpv").style.display = ''
    document.getElementById("arvr").style.display = ''
   }
  }
  if(owner_finance.checked)
  {
   if(property_type_value != '')
    {
     document.getElementById("maxmp").style.display = ''
     document.getElementById("maxdp").style.display = ''
    }
  }
  if(!wholesale.checked)
  {
   document.getElementById("maxpv").style.display = 'none'
   document.getElementById("arvr").style.display = 'none'
  }
  if(!owner_finance.checked)
  {

      document.getElementById("maxmp").style.display = 'none'
      document.getElementById("maxdp").style.display = 'none'

  }
 }

function get_wholesale_owner_finance_value_for_buyer_profile(){
  wholesale = document.getElementById("wholesale")
  owner_finance = document.getElementById("owner_finance")
  if(!wholesale.checked && !owner_finance.checked)
  {
    document.getElementById("wholesale_section").style.display = 'block'
    document.getElementById("owner_finance_section").style.display = 'none'
    document.getElementById("map_block").style.display = 'none'
    document.getElementById("msg_block").style.display = 'none'
    alert("Please select any investment type before proceding further")
  }
  else{
  if(wholesale.checked || (wholesale.checked && owner_finance.checked))
  {
    document.getElementById("wholesale_section").style.display = 'block'
    document.getElementById("owner_finance_section").style.display = 'none'
    document.getElementById("map_block").style.display = 'none'
    document.getElementById("msg_block").style.display = 'none'
  }
  if(owner_finance.checked && !wholesale.checked)
  {
   document.getElementById("owner_finance_section").style.display = 'block'
   document.getElementById("map_block").style.display = 'block'
   document.getElementById("msg_block").style.display = 'block'
   document.getElementById("wholesale_section").style.display = 'none'
   load_map();
  }
  }
 }

function edit_wholesale_owner_finance_value(p_t){
  wholesale = document.getElementById("wholesale")
  owner_finance = document.getElementById("owner_finance")
  property_type_value = p_t
  if(wholesale.checked)
  {
    document.getElementById("maxpv").style.display = ''
    document.getElementById("arvr").style.display = ''
  }
  if(owner_finance.checked)
  {

      document.getElementById("maxmp").style.display = ''
      document.getElementById("maxdp").style.display = ''

  }
  if(!wholesale.checked)
  {
   document.getElementById("maxpv").style.display = 'none'
   document.getElementById("arvr").style.display = 'none'
  }
  if(!owner_finance.checked)
  {

      document.getElementById("maxmp").style.display = 'none'
      document.getElementById("maxdp").style.display = 'none'

  }
}

function get_state_county(){
      county_state = $('county_state').value
      new Ajax.Request('/profiles/get_county_for_state?state_id='+county_state,
      {
          method:'get',
          onSuccess: function(transport){
             var response = transport.responseText || "no response text";
             $('ajax_county_update_div').innerHTML = response
          },
          onFailure: function(){ alert('Something went wrong...') }
      });
   }