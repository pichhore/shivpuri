class CreateSellerLeadTestimonails < ActiveRecord::Migration
  def self.up
    exists = SellerLeadTestimonail.table_exists? rescue false
    if !exists
      create_table :seller_lead_testimonails do |t|
        t.text :subject
        t.text :testimonial
        t.timestamps
      end
    end
    SellerLeadTestimonail.create(:subject => "<b>We just wanted to say thank you </b><br><br>",
                               :testimonial => "<i>We just wanted to say thank you so much for helping us find our first home.  When we first started looking at houses it was a daunting experience, we felt as though we would never be ready to do a conventional mortgage.  You stepped in and made it so easy, You quickly learned what My wife and I were looking for and you never stopped looking out for us.  You made us feel welcome and helped to put us at ease.  You found the perfect house for us and we could not be happier.  You took all the uncertainty out of the buying experience and explained it so easily that when we got to the title office we knew everything that we needed and it took us less than 30 minutes .  It is still hard to believe that we were able to walk into a house so effortlessly.   Again we can not thank you enough for all of your help all of my friends cant believe how effortless buying our first home was (they all went conventional and told me nothing but horror stories about their experience).</i><br><br>

                               Best Wishes<br>
                               <b>Joe & Victoria, Homebuyers</b><br><br>")

  end

  def self.down
    exists = SellerLeadTestimonail.table_exists? rescue false
    if exists
    drop_table :seller_lead_testimonails
    end
  end
end
