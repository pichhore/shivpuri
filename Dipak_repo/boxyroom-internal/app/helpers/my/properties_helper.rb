module My::PropertiesHelper

  def get_file_content_icon(doc_content_type)
#     content_type = File.mime_type(doc.document.url)
#     image_tag("home-search-btn.png") if doc_content_type.include?("image")
#        image_tag("pdf_icon.jpg") if doc_content_type.include?("application/pdf")
     if doc_content_type.include?("image")
        return image_tag("image-icon.png")
     elsif doc_content_type.include?("application/pdf")
        return image_tag("pdf-icon.jpg")
     elsif doc_content_type.include?("text/html")
        return image_tag("html-icon-.png")
     elsif doc_content_type.include?("text/") or doc_content_type.include?("application/vnd.ms-excel") or doc_content_type.include?("application/plain") or doc_content_type.include?("application/plain") or doc_content_type.include?("application/msword")
        return image_tag("text_icon.gif")
		
     end
  end
  # To show selected index in sort_by[Search] drop down 
  def selected_search_by(option_name)
    "selected=\"selected\"" if params[:searchby].to_s==option_name
  end

end
