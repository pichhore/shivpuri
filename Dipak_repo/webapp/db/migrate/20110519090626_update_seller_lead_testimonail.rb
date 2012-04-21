class UpdateSellerLeadTestimonail < ActiveRecord::Migration
  def self.up
  testimonial = SellerLeadTestimonail.find(:first)
  testimonial.destroy
  
  testimonial1 = SellerLeadTestimonail.create(:subject => "<b>We just wanted to say thank you </b><br><br>",:testimonial => "<i>“I needed to sell a home in 48 hours. Phill and his team were able to get the deal done!”</i><br><br>Best Wishes<br><b>Lane R </b><br><br>")
  testimonial1.save

  testimonial2 = SellerLeadTestimonail.create(:subject => "<b>We just wanted to say thank you </b><br><br>",:testimonial => "<i>“I live in Ohio and needed to sell a home I inherited in Austin. You guys bought it for cash in less than a week.”</i><br><br>Best Wishes<br><b>Tom B </b><br><br>")
  testimonial2.save

  testimonial3 = SellerLeadTestimonail.create(:subject => "<b>We just wanted to say thank you </b><br><br>",:testimonial => "<i>“I wanted to sell my home quickly and tried everything. your company agreed to take over my mortgage payments.Success!!”</i><br><br>Best Wishes<br><b>Terry C </b><br><br>")
  testimonial3.save

  testimonial4 = SellerLeadTestimonail.create(:subject => "<b>We just wanted to say thank you </b><br><br>",:testimonial => "<i>“We tried to sell the home but we owed too much and were having trouble keeping the payments going. Phill was able to negotiate our loan with our lender and sell the home for us. Without them, a foreclosure was inevitable!”</i><br><br>Best Wishes<br><b>Shannon N </b><br><br>")
  testimonial4.save

  testimonial5 = SellerLeadTestimonail.create(:subject => "<b>We just wanted to say thank you </b><br><br>",:testimonial => "<i>“The bank was about to foreclose on us. You came in and stopped the foreclosure and then bought our home through a short sale. Our credit was saved and the problem gone!”</i><br><br>Best Wishes<br><b>Terry and Chandra R </b><br><br>")
  testimonial5.save

  testimonial6 = SellerLeadTestimonail.create(:subject => "<b>We just wanted to say thank you </b><br><br>",:testimonial => "<i>“I considered selling the home quickly for cash but then decided to let them try to list it for me first (with their cash offer as a backup). As it turned out, they found me a buyer and I made more money!” </i><br><br>
  Best Wishes<br><b>Saundra E </b><br><br>")
  testimonial6.save
  end

  def self.down
  end
end
