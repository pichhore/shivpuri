function set_scratch_pad(){
  if ( $("seller_engagement_info_description") ){
    var note_text = $("seller_engagement_info_description").value;
    var seller_lead_id = $("seller_lead_id").value;
//     var subject = $("seller_engagement_info_subject").value;
//     var tag = $("seller_engagement_info_scratch_pad_tag").value;
    new Ajax.Request(
      '/seller_websites/set_scratch_pad_note',
      {
        method: 'post',
        parameters: { note_text: note_text, seller_lead_id: seller_lead_id},
//         parameters: { note_text: note_text, subject: subject, tag: tag},
        onSuccess: function(transport){
              //var response = transport.responseText || "no response text";
             // alert("Success! \n\n" + response);
       },
       onFailure: function(){
          alert('Something went wrong...')
       }

      })
  }
  else if( $("buyer_engagement_info_description") ){
    var note_text_buyer = $("buyer_engagement_info_description").value;
    var buyer_lead_id = $("buyer_lead_id").value;
    new Ajax.Request(
      '/buyer_websites/set_scratch_pad_note',
      {
        method: 'get',
        parameters: { note_text_buyer: note_text_buyer, buyer_lead_id: buyer_lead_id},
        asynchronous:false,
        onSuccess: function(transport){
       },
       onFailure: function(){
          alert('Something went wrong...')
       }

      })
  }
}

function navigate_seller_tab(url)
{
    set_scratch_pad();
    window.location = url;
}

function navigate_buyer_tab(url)
{
    set_scratch_pad();
    window.location = url;
}

function discard_scratch_pad_lightbox(){
    if ( $("seller_engagement_info_description") ){
    var note_text = $("seller_engagement_info_description").value;
    new Ajax.Request(
      '/seller_websites/discard_scratch_pad_note_lightbox',
      {
        method: 'get',
        parameters: { note_text: note_text },
        onSuccess: function(transport){
              //var response = transport.responseText || "no response text";
             // alert("Success! \n\n" + response);
       },
       onFailure: function(){
          alert('Something went wrong...')
       }

      })
}
else if( $("buyer_engagement_info_description") ){
    var note_text_buyer = $("buyer_engagement_info_description").value;
    new Ajax.Request(
      '/buyer_websites/discard_scratch_pad_note_lightbox',
      {
        method: 'get',
        parameters: { note_text_buyer: note_text_buyer },
        onSuccess: function(transport){
             },
       onFailure: function(){
          alert('Something went wrong...')
       }

      })
}
}
