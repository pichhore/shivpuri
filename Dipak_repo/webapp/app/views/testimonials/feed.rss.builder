xml.instruct! :xml, :version => "1.0"
xml.rss (:version => "2.0", "xmlns:ts" => "#{REIMATCHER_URL}testimonials/pg_feed.rss") do
  xml.channel do
    xml.title "#{@title} Testimonials"
    xml.description "#{@title} Testimonials"
    xml.link "#{REIMATCHER_URL}testimonials/pg_feed.rss"

    for testimonial in @testimonials
      xml.item do
        xml.title testimonial.address
        xml.link "http://reimatcher.com/testimonials/pg_feed.rss"
        xml.tag!("ts:testimonial_id", testimonial.id)
        xml.tag!("ts:investor_firstname", testimonial.investor_fname)
        xml.tag!("ts:investor_lastname", testimonial.investor_lname)
        xml.tag!("ts:investor_email", testimonial.email)
        xml.tag!("ts:investor_phone", testimonial.phone_number)
        xml.tag!("ts:investor_address", testimonial.address)
        xml.tag!("ts:closing_date", testimonial.closing_date.strftime("%m/%d/%Y"))
        xml.tag!("ts:strategies_used", testimonial.strategies)
        xml.tag!("ts:final_sales_price", testimonial.sales_price)
        xml.tag!("ts:sales_estimate", testimonial.sales_estimate)
        xml.tag!("ts:gross_profit", testimonial.gross_profit)
        xml.tag!("ts:lifetime_cash_flow", testimonial.cash_flow)
        xml.tag!("ts:deal_source", testimonial.deal_source)
        xml.tag!("ts:issues_or_problems", testimonial.problems_faced)
        xml.tag!("ts:tools_helped", testimonial.tools_used)
        xml.tag!("ts:other_tools_info", testimonial.other_tools)
        xml.tag!("ts:comments", testimonial.comments)
        xml.tag!("ts:lessons_or_tips", testimonial.lessons_or_tips)
        xml.tag!("ts:picture_types", testimonial.picture_types)
        pictures = testimonial.testimonial_pictures
        for picture in pictures
          xml.tag!("ts:image#{pictures.index(picture)}", "#{REIMATCHER_URL}#{picture.public_filename.match('/(.*)')[1]}")
        end
        xml.tag!("ts:marketing_release", testimonial.market_release)
        xml.tag!("ts:last_modified_at", testimonial.updated_at)
      end
    end
  end
end