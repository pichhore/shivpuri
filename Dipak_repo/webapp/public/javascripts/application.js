/**
 * Various helpers and utils needed by all screens.
 *
 * Note: the NL Javascript namespace is created in the base_controller script.
 */


/*
 * Adds a loading message to the back of any Google map in case it takes a while to load.
 */
function addMapLoadingReport(){ 
    // Text to display 
    var loadingText = 'Loading Map...'; 
    // Create a new element 
    var info = document.createElement('div'); 
    info.appendChild(document.createTextNode(loadingText)); 
    // Add an id to the element, in case you want to access it later 
    info.setAttribute('id', 'mapLoading'); 
    // Insert into map container 
    this.getContainer().insertBefore(info, this.getContainer().firstChild); 
} 

function changeUserType(){
        if ( $("record_user_type").value  == "1"  || $("record_user_type").value  == 1 )
        {$("infusionsoft_contact_id").show();}
        else
        {$("infusionsoft_contact_id").hide();}
    }