module ProfilesHelper
  def style_if_new(profile_message_recipient)
    count = ProfileMessageRecipient.count_new_to_from(profile_message_recipient.to_profile_id, profile_message_recipient.from_profile_id)
    return "new" if (count > 0)
    return ""
  end

  def syndication_time site_id
    site = ProfileSite.find_by_profile_id_and_site_id(@profile_id, site_id)
    site.updated_at if site
  end

  def get_flyer_html(random_string)
    profile = Profile.find_by_random_string(random_string)
    profile_id = random_string if profile.nil?
    profile_id = profile.id if !profile.nil?
    profile = Profile.find_by_id(random_string) if profile.nil?
    profile_fields = ProfileField.find_all_by_profile_id(profile_id)
    profile_images = ProfileImage.find_all_by_profile_id(profile_id, :conditions => {:thumbnail => "big"})
    profile_fields_hash = {}
    profile_fields.each do |profile_field|
      profile_fields_hash[profile_field.key] = profile_field.value
      profile_fields_hash[profile_field.key] = profile_field.value_text if profile_field.key == "description"
    end
    @zip = Zip.find_by_zip(profile_fields_hash["zip_code"])
    if profile.investment_type_id == 1
      property_investment_type = "Owner-financed"
    elsif profile.investment_type_id == 2
      property_investment_type = "Wholesale"
    else
      property_investment_type = "Wholesale And Owner-financed"
    end
    profile_user = profile.user
    user_company = profile_user.user_company_info if !profile_user.nil?
    user_company_image = UserCompanyImage.find_by_user_id(profile_user.id, :conditions => {:thumbnail => 'profile'}) 
    flyer_html = '
<html>
<head>

   <title>REI</title>

</head>

<body>
<table width="960" border="0" cellspacing="0" cellpadding="20" style="border: solid 2px #000; font-family:Arial, Helvetica, sans-serif">
  <tr>
    <td height="30" colspan="2" bgcolor="#000000"><font size="5" color="#CCCCCC">'+property_investment_type+' Property for Sale</font></td>
  </tr>
  <tr>
    <td height="" colspan="2">
    <table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td width="33%" rowspan="2" ><img style="border: solid 2px #000" src="'+ get_default_image(profile_id, profile_images) + '" width="274" height="183" /></td>
        <td width="31%" rowspan="2" valign="top">
          <p><b><font size="4">' + check_for_null(profile_fields_hash["property_address"]) + '<br />' +
            @zip.city + ', ' + @zip.state + '<br />
            $' + check_for_null(profile_fields_hash["price"]) + '</font></b></p>
          <p><a href=' + REIMATCHER_URL + "home/preview_owner/" + profile_id + ' target="_blank"><img src=' + REIMATCHER_URL + "images/flyer_html/btnViewProperty.png" + ' width="194" height="50" border="0" alt="button" /></a></p>
          <p> '+ get_video_tour(profile_fields_hash["video_tour"]) + ' </p></td>
        <td width="12%">&nbsp;</td>
        <td width="24%" valign="top" rowspan="2" style="text-align:right"> </td> 
        </tr>
      <tr>
        <td>&nbsp;</td>
        </tr>
    </table></td>
  </tr>
  <tr>
    <td colspan="2" style="background-image:url(' + REIMATCHER_URL + "images/flyer_html/bodyBg.jpg" + '); background-repeat: repeat-x"><table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td width="35%"></td>
        <td width="2%" rowspan="2"><p>&nbsp;</p></td>
        <td width="63%" rowspan="2" valign="top"><p><b>Property Description</b></p>' + 
     check_for_null(profile_fields_hash["description"]) + '</td>
        </tr>
      <tr>
        <td valign="top"><p><b>Property Details</b></p>
          <table width="100%" border="0" cellspacing="0" cellpadding="3">
          <tr>
            <td width="36%"><b>Price:</b></td>
            <td width="64%">$' + check_for_null(profile_fields_hash["price"]) + '</td>
          </tr>
          <tr>
            <td bgcolor="#E5E5E5"><b>Bedrooms:</b></td>
            <td bgcolor="#E5E5E5">' + check_for_null(profile_fields_hash["beds"]) + '</td>
          </tr>
          <tr>
            <td><b>Bathrooms:</b></td>
            <td>' + check_for_null(property_bathrooms_hash(profile_fields_hash["baths"])) + ' </td>
          </tr>
          <tr>
            <td bgcolor="#E5E5E5"><b>Square Feet:</b></td>
            <td bgcolor="#E5E5E5">' + check_for_null(profile_fields_hash["square_feet"]) + ' sqft</td>
          </tr>
          <tr>
            <td><b>Address:</b></td>
            <td>' + check_for_null(profile_fields_hash["property_address"]) + '</td>
          </tr>
          <tr>
            <td bgcolor="#E5E5E5"><b>City/Locality:</b></td>
            <td bgcolor="#E5E5E5">' + @zip.city + ', ' + @zip.state + '</td>
          </tr>
        </table></td>
      </tr>
    </table>
    <p><b>Property Photos</b></p>
    <table width="100%" border="0" cellspacing="0" cellpadding="0"> <tr>' + 
        get_profile_pictures(profile_images) +
      '</tr></table>
      <hr />
    <p>Contact Info:</p>
    <table width="300" border="0" cellspacing="0" cellpadding="0">
      <tr>
      <td width="120"><img src='+ get_company_logo(user_company_image)+'  width="100" height="85"/></td>
       <td width="205"><font size="3">'+ get_primary_contact_and_company_info(user_company, profile_user, profile) +' </font></td>

      </tr>
    </table>
  </td>
  </tr>
  <tr>
    <td bgcolor="#000000" width="628"><a href=' + REIMATCHER_URL + ' target="_blank"><img src=' + REIMATCHER_URL + "images/flyer_html/poweredByREIM.png" + ' width="199" height="37" border="0" alt="Powered by REI" /></a></td>
    <td bgcolor="#000000" width="266" style="text-align:right"><img src=' + REIMATCHER_URL + "images/flyer_html/equalHouse.png" + ' width="172" height="18" alt="Equal Opportunity Housing" /></td>
  </tr>
</table>
</body>

</html>'

    return flyer_html    
  end

  def get_profile_pictures(profile_images)
    images_html = ''
    image_count = 0
    profile_images.each do |image|
      image_count = image_count + 1
      image_link = REIMATCHER_URL + "profile_images/#{image.parent_id}/#{image.filename}" 
      images_html = images_html + '<td align="center"><img src='+ image_link  +' alt="house" width="274" height="183" style="border: solid 2px #000;"/><p style="margin-top: 0px;">&nbsp;<!--Front--></p></td>'
      images_html = images_html + ' </tr><tr>' if image_count == 3
      break if image_count == 6
    end
    
    (6 - profile_images.length).times do 
      image_count = image_count + 1
      image_link = REIMATCHER_URL + "images/property-170.jpg"      
      images_html = images_html + '<td align="center"><img src='+ image_link  +' alt="house" width="274" height="183" style="border: solid 2px #000;" /><p style="margin-top: 0px;">&nbsp;<!--Front--></p></td>'
      images_html = images_html + ' </tr><tr>' if image_count == 3
    end
    return images_html
  end

  def get_default_image(profile_id, profile_images)
    default_image = ProfileImage.find_by_profile_id(profile_id, :conditions => {:default_photo => true})
    image_url = REIMATCHER_URL + "images/property-170.jpg"
    image_url = REIMATCHER_URL + "profile_images/#{default_image.id}/#{default_image.filename}" if !default_image.nil?
    image_url = REIMATCHER_URL + "profile_images/#{profile_images.first.parent_id}/#{profile_images.first.filename}" if default_image.nil? && !profile_images.blank?
    return image_url
  end

  def get_company_logo(company_image)
    company_logo = ""
    company_logo = REIMATCHER_URL + "user_company_images/#{company_image.parent_id}/#{company_image.filename}" if !company_image.nil?
    return company_logo
  end

  def get_company_info(user_company, profile_user)
    company_info = ""
    if !profile_user.nil?
      company_info = "#{profile_user.first_name} #{profile_user.last_name}".strip + "<br />" + user_company.business_name + "<br />" + user_company.business_address + "<br />"+ user_company.city + ", " + user_company.state +  "<br />" + user_company.business_phone if !user_company.nil?
    else
      company_info = user_company.business_name + "<br />" + user_company.business_address + "<br />"+ user_company.city + ", " + user_company.state +  "<br />" + user_company.business_phone if !user_company.nil?
    end
    return company_info
  end

  def get_primary_contact_and_company_info(user_company, profile_user, profile)
    company_info = ""
    if !profile_user.nil?
      company_info = "#{profile.contact_name.blank? ? "#{profile_user.first_name.to_s + ' ' + profile_user.last_name.to_s}" : profile.contact_name}".strip + "<br />" + user_company.business_name + "<br />" + user_company.business_address + "<br />"+ user_company.city + ", " + user_company.state +  "<br />" + "#{profile.contact_phone.blank? ? profile.user.user_company_info.business_phone : profile.contact_phone}" if !user_company.nil?
    else
      company_info = user_company.business_name + "<br />" + user_company.business_address + "<br />"+ user_company.city + ", " + user_company.state +  "<br />" + user_company.business_phone if !user_company.nil?
    end
    return company_info
  end

  ## Added to check for missing attributes
  ## for old properties
  def check_for_null(value)
    if !value.nil?
      return value 
    else
      return ""
    end
  end

  def get_video_tour(video_tour)
    video_url = '<a href=http://'+ video_tour +' target="_blank"><img src=' + REIMATCHER_URL + "images/flyer_html/btnTakeVideoTour.png" + ' width="195" height="41" border="0" alt="button" /></a>' if !video_tour.blank?
    video_url = "" if video_tour.blank?
    return video_url
  end

  def display_page_title_for_delete_reason
    return (@profile.buyer? or @profile.buyer_agent?) ? "Delete Buyer - #{@profile.private_display_name}?" : "Delete Property - #{@profile.display_name}?"
  end

  def display_profile_name_to_be_deleted
    return (@profile.buyer? or @profile.buyer_agent?) ? "Buyer Profile" : "Property"
  end

  def property_bathrooms_hash(value)
    bath_hash = { "1"  => "1",
      "2"  => "1.5",
      "3"  => "2",
      "4"  => "2.5",
      "5"  => "3",
      "7"  => "4",
      "9"  => "5",
      "11" => "6+",
    }
    return bath_hash[value]
  end
end
