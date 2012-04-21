function get_property_value(y){
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
        document.getElementById("arv").style.display = ''
        document.getElementById("vbm").style.display = ''
        document.getElementById("trn").style.display = ''
        document.getElementById("rcb").style.display = ''
      }

     if((select_property_type == 'single_family' || select_property_type == 'acreage' ) && owner_finance.checked == true)
     {
       document.getElementById("minmp").style.display = ''
       document.getElementById("mindp").style.display = ''
     }
    }
 }

 function get_wholesale_owner_finance_value(x){
  wholesale_owner_finance_values = document.getElementById(x)
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
      document.getElementById("arv").style.display = ''
      document.getElementById("vbm").style.display = ''
      document.getElementById("trn").style.display = ''
      document.getElementById("rcb").style.display = ''
     }
   }
  if(owner_finance.checked)
   {
     if(property_type_value == 'single_family' || property_type_value == 'acreage')
     {
      document.getElementById("minmp").style.display = ''
      document.getElementById("mindp").style.display = ''
     }
   }
  if(!wholesale.checked)
  {
   document.getElementById("arv").style.display = 'none'
   document.getElementById("vbm").style.display = 'none'
   document.getElementById("trn").style.display = 'none'
   document.getElementById("rcb").style.display = 'none'
  }

  if(!owner_finance.checked)
  {
    if(property_type_value == 'single_family' || property_type_value == 'acreage' || property_type_value == '')
    {
      document.getElementById("minmp").style.display = 'none'
      document.getElementById("mindp").style.display = 'none'
    }
  }
 }

function edit_wholesale_owner_finance_value(p_t){
  wholesale = document.getElementById("wholesale")
  owner_finance = document.getElementById("owner_finance")
  property_type_value = p_t
  if(wholesale.checked)
   {
    document.getElementById("arv").style.display = ''
    document.getElementById("vbm").style.display = ''
    document.getElementById("trn").style.display = ''
    document.getElementById("rcb").style.display = ''
   }
  if(owner_finance.checked)
   {
     if(property_type_value == 'single_family' || property_type_value == 'acreage')
     {
      document.getElementById("minmp").style.display = ''
      document.getElementById("mindp").style.display = ''
     }
   }
  if(!wholesale.checked)
  {
   document.getElementById("arv").style.display = 'none'
   document.getElementById("vbm").style.display = 'none'
   document.getElementById("trn").style.display = 'none'
   document.getElementById("rcb").style.display = 'none'
  }

  if(!owner_finance.checked)
  {
    if(property_type_value == 'single_family' || property_type_value == 'acreage')
    {
      document.getElementById("minmp").style.display = 'none'
      document.getElementById("mindp").style.display = 'none'
    }
  }
 }






