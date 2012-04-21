function show_domain_info(this_id)
{
    if(this_id=='buying_domain')
    {
        $('buying_domain').show();
        $('having_domain').hide();
        $('reim_domain').hide();
    }
    else if (this_id=='having_domain')
    {
        $('buying_domain').hide();
        $('having_domain').show();
        $('reim_domain').hide();
    }
    else if(this_id=='reim_domain')
    {
        $('buying_domain').hide();
        $('having_domain').hide();
        $('reim_domain').show();
    }
}

function check_availablity(selected_domain,permalink_id,site_type) 
{
    var domain_name ;
    $('ajax_update_div_1').innerHTML ="";
    $('ajax_update_div_2').innerHTML = "";
    if ($(selected_domain).checked)
        domain_name = $(selected_domain).value;
    permalink = $(permalink_id).value;
    new Ajax.Request('/'+site_type+'/check_permalink',
		     {
			 method:'POST',
			 parameters: { domain_name: domain_name, permalink: permalink},
			 onSuccess: function(transport){
			     var response = transport.responseText || "no response text";
			     if (permalink_id=="my_website_form_reim_domain_permalink1") {
				 $('ajax_update_div_1').innerHTML = response; 
				 $('ajax_update_div_2').innerHTML = "";
			     }
			     else if (permalink_id=="my_website_form_reim_domain_permalink2"){
				 $('ajax_update_div_2').innerHTML = response; 
				 $('ajax_update_div_1').innerHTML = "";
			     }
			 },
			 onFailure: function(){ alert('Something went wrong...') },
			 onLoading: function(){ 
			     if (permalink_id=="my_website_form_reim_domain_permalink2")
			     { 
				 $('feeds_spinner_2').show(); 
			     }
			     else if (permalink_id=="my_website_form_reim_domain_permalink1")
			     {
				 $('feeds_spinner_1').show();
			     }
			 },
			 onComplete: function()
			 {
			     $('feeds_spinner_2').hide();
			     $('feeds_spinner_1').hide();
			 }
		     });
}

function checked_radio_button_1(website_domain1){
    document.getElementById('my_website_form_reim_domain_name_'+website_domain1).checked = true;
}

function checked_radio_button_2(website_domain2){
    document.getElementById('my_website_form_reim_domain_name_'+website_domain2).checked = true;
}

function select_website(e,ele_id,website_domain1,website_domain2)
{
    var KeyID = (window.event) ? event.keyCode : e.keyCode;
    switch(KeyID)
    {
    case 9:
        if (ele_id == 'my_website_form_reim_domain_permalink2')
        {
            $('my_website_form_reim_domain_name_'+website_domain2).checked = true;
        }
        else if (ele_id == 'my_website_form_reim_domain_permalink1')
        {
            $('my_website_form_reim_domain_name_'+website_domain1).checked = true;
        }
        break; 
    }
}